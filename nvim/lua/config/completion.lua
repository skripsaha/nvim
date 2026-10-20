local Completion = {}
local PendingFunctionCursor = {}

local CompletionKinds = {
  [2] = "m",
  [3] = "f",
  [4] = "c",
  [5] = "f",
  [6] = "v",
  [7] = "v",
  [8] = "k",
  [9] = "i",
  [10] = "f",
  [11] = "m",
  [12] = "p",
  [13] = "v",
  [14] = "e",
  [15] = "u",
  [16] = "v",
  [17] = "e",
  [18] = "v",
  [19] = "f",
  [20] = "v",
  [21] = "s",
  [22] = "k",
  [23] = "c",
  [24] = "e",
  [25] = "r",
}

local function InsertAtCursor(text)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local column = cursor[2]
  vim.api.nvim_buf_set_text(0, row, column, row, column, { text })
  vim.api.nvim_win_set_cursor(0, { row + 1, column + #text })
end

local function InsertIndent()
  if vim.bo.expandtab then
    InsertAtCursor(string.rep(" ", vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 4))
  else
    InsertAtCursor("\t")
  end
end

local function LongestCommonPrefix(values)
  if #values == 0 then
    return ""
  end

  local prefix = values[1]
  for index = 2, #values do
    local value = values[index]
    local length = 0
    while length < #prefix
        and length < #value
        and prefix:sub(length + 1, length + 1) == value:sub(length + 1, length + 1) do
      length = length + 1
    end
    prefix = prefix:sub(1, length)
    if prefix == "" then
      break
    end
  end
  return prefix
end

local function CompletionText(item)
  local text_edit = item.textEdit
  local text = type(text_edit) == "table" and text_edit.newText or item.insertText or item.label
  if type(text) ~= "string" then
    return nil
  end

  -- Remove the simple snippet placeholders used by most C/C++ servers.
  text = text:gsub("%${%d+:([^}]*)}", "%1"):gsub("%$%d+", "")

  -- clangd labels functions with their call suffix even when insertText omits it.
  if (item.kind == 2 or item.kind == 3 or item.kind == 4) and not text:find("%(") then
    local label = item.label
    if type(label) == "string" and label:find("%(") then
      text = label
    end
  end
  return text
end

local function CurrentWord()
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = line:sub(1, column)
  local prefix = before_cursor:match("[A-Za-z_][A-Za-z0-9_]*$") or ""
  return prefix, column - #prefix
end

local function PopupKey(key, fallback)
  if vim.fn.pumvisible() == 1 then
    return vim.keycode(key)
  end
  return fallback
end

local function CompletionEntries(responses, prefix)
  local entries = {}
  local seen = {}

  for _, response in pairs(responses) do
    local result = response.result
    local items = result and (result.items or result) or {}
    if type(items) == "table" then
      for _, item in ipairs(items) do
        local text = CompletionText(item)
        if text and vim.startswith(text, prefix) and not seen[text] then
          seen[text] = true
          entries[#entries + 1] = {
            word = text,
            abbr = item.label or text,
            kind = CompletionKinds[item.kind] or "",
          }
        end
      end
    end
  end

  return entries
end

function Completion.CompleteDone()
  local bufnr = vim.api.nvim_get_current_buf()
  local pending = PendingFunctionCursor[bufnr]
  PendingFunctionCursor[bufnr] = nil
  local completed_item = vim.v.completed_item
  if not pending or type(completed_item) ~= "table" or type(completed_item.word) ~= "string" then
    return
  end

  local opening_parenthesis = completed_item.word:find("(", 1, true)
  if not opening_parenthesis then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  if cursor[1] == pending.row and cursor[2] >= pending.start_column then
    vim.api.nvim_win_set_cursor(0, { pending.row, pending.start_column + opening_parenthesis })
  end
end

function Completion.ConfigureBuffer(bufnr)
  local expr = function(key, fallback)
    return function()
      return PopupKey(key, fallback)
    end
  end

  vim.keymap.set("i", "j", expr("<C-n>", "j"), {
    buffer = bufnr,
    expr = true,
    replace_keycodes = true,
    desc = "Next completion item",
  })
  vim.keymap.set("i", "k", expr("<C-p>", "k"), {
    buffer = bufnr,
    expr = true,
    replace_keycodes = true,
    desc = "Previous completion item",
  })
  vim.keymap.set("i", "<CR>", expr("<C-y>", "<CR>"), {
    buffer = bufnr,
    expr = true,
    replace_keycodes = true,
    desc = "Accept completion item",
  })
  vim.keymap.set("i", "q", expr("<C-e>", "q"), {
    buffer = bufnr,
    expr = true,
    replace_keycodes = true,
    desc = "Close completion menu",
  })
end

function Completion.Tab()
  if vim.fn.pumvisible() == 1 then
    vim.api.nvim_feedkeys(vim.keycode("<C-e>"), "n", false)
    return
  end

  local prefix, start_column = CurrentWord()
  if prefix == "" then
    InsertIndent()
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local completion_client = false
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/completion") then
      completion_client = true
      break
    end
  end
  if not completion_client then
    InsertIndent()
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local bufnr = vim.api.nvim_get_current_buf()
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local params = vim.lsp.util.make_position_params(0, "utf-16")
  local completed = false

  local function FinishWithIndent()
    if not completed then
      completed = true
      InsertIndent()
    end
  end

  vim.defer_fn(FinishWithIndent, 300)
  vim.lsp.buf_request_all(0, "textDocument/completion", params, function(responses)
    if completed then
      return
    end

    local entries = CompletionEntries(responses, prefix)
    local values = vim.tbl_map(function(entry)
      return entry.word
    end, entries)
    if #values == 0 then
      FinishWithIndent()
      return
    end

    completed = true
    if #entries == 1 then
      local completion = values[1]
      local extension = completion:sub(#prefix + 1)
      if extension == "" then
        return
      end

      vim.schedule(function()
        if vim.api.nvim_get_current_buf() ~= bufnr
            or vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick
            or vim.fn.mode():sub(1, 1) ~= "i" then
          return
        end
        local current_cursor = vim.api.nvim_win_get_cursor(0)
        if current_cursor[1] == cursor[1] and current_cursor[2] == cursor[2] then
          vim.api.nvim_buf_set_text(bufnr, cursor[1] - 1, start_column, cursor[1] - 1, cursor[2], { completion })
          local cursor_offset = completion:find("(", 1, true) or #completion
          vim.api.nvim_win_set_cursor(0, { cursor[1], start_column + cursor_offset })
        end
      end)
    else
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() ~= bufnr
            or vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick
            or vim.fn.mode():sub(1, 1) ~= "i" then
          return
        end

        local current_cursor = vim.api.nvim_win_get_cursor(0)
        if current_cursor[1] ~= cursor[1] or current_cursor[2] ~= cursor[2] then
          return
        end

        local common = LongestCommonPrefix(values)
        if #common > #prefix then
          vim.api.nvim_buf_set_text(bufnr, cursor[1] - 1, start_column, cursor[1] - 1, cursor[2], { common })
          vim.api.nvim_win_set_cursor(0, { cursor[1], start_column + #common })
        end

        PendingFunctionCursor[bufnr] = {
          row = cursor[1],
          start_column = start_column,
        }
        vim.fn.complete(start_column + 1, entries)
      end)
    end
  end)
end

vim.api.nvim_create_autocmd("CompleteDone", {
  group = vim.api.nvim_create_augroup("user_completion", { clear = true }),
  callback = Completion.CompleteDone,
})

return Completion
