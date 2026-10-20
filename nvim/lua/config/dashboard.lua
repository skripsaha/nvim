local M = {}

local namespace = vim.api.nvim_create_namespace("user_dashboard")

-- Official filled Vim ASCII logo from https://www.vim.org/images/vim.txt
-- by Erling Westenvik. V forms the light letter, + the green diamond behind
-- it, and # forms the bright part of the wordmark.
local vim_logo = {
  "        ________ ++     ________",
  "       /VVVVVVVV\\++++  /VVVVVVVV\\",
  "       \\VVVVVVVV/++++++\\VVVVVVVV/",
  "        |VVVVVV|++++++++/VVVVV/'",
  "        |VVVVVV|++++++/VVVVV/'",
  "       +|VVVVVV|++++/VVVVV/'+",
  "     +++|VVVVVV|++/VVVVV/'+++++",
  "   +++++|VVVVVV|/VVV___++++++++++",
  "     +++|VVVVVVVVVV/##/ +_+_+_+_",
  "       +|VVVVVVVVV___ +/#_#,#_#,\\",
  "        |VVVVVVV//##/+/#/+/#/'/#/",
  "        |VVVVV/'+/#/+/#/+/#/ /#/",
  "        |VVV/'++/#/+/#/ /#/ /#/",
  "        'V/'  /##//##//##//###/",
  "                 ++",
}

local actions = {
  { key = "f", label = "find file", command = "FzfLua files" },
  { key = "r", label = "recent files", command = "FzfLua oldfiles" },
  { key = "e", label = "file tree", command = "NvimTreeToggle" },
  { key = "h", label = "vim guide", command = "VimGuide" },
  { key = "p", label = "practice", command = "VimPractice" },
  { key = "n", label = "empty buffer", command = "enew" },
  { key = "q", label = "quit", command = "quit" },
}

local function display_width(text)
  return vim.fn.strdisplaywidth(text)
end

local function centered_prefix(text, width)
  return string.rep(" ", math.max(math.floor((width - display_width(text)) / 2), 0))
end

local function add_highlight(highlights, line, first, last, group)
  highlights[#highlights + 1] = {
    line = line,
    first = first,
    last = last,
    group = group,
  }
end

local function add_logo_lines(lines, highlights, width)
  local logo_width = 0
  for _, content in ipairs(vim_logo) do
    logo_width = math.max(logo_width, display_width(content))
  end
  local prefix = string.rep(" ", math.max(math.floor((width - logo_width) / 2), 0))

  for _, content in ipairs(vim_logo) do
    local line = #lines
    lines[#lines + 1] = prefix .. content
    add_highlight(highlights, line, #prefix, -1, "DashboardVimText")

    local active_group
    local range_start
    for column = 1, #content + 1 do
      local character = content:sub(column, column)
      local group = character == "V" and "DashboardVimLetter"
        or character == "+" and "DashboardVimDiamond"
        or character == "#" and "DashboardVimBright"
        or nil

      if group ~= active_group then
        if active_group then
          add_highlight(
            highlights,
            line,
            #prefix + range_start - 1,
            #prefix + column - 1,
            active_group
          )
        end

        active_group = group
        range_start = group and column or nil
      end

      if column > #content and active_group then
        add_highlight(
          highlights,
          line,
          #prefix + range_start - 1,
          #prefix + #content,
          active_group
        )
      end
    end
  end
end

local function add_action_line(lines, highlights, width, items)
  local parts = {}
  for _, action in ipairs(items) do
    parts[#parts + 1] = "[" .. action.key .. "] " .. action.label
  end

  local content = table.concat(parts, "     ")
  local prefix = centered_prefix(content, width)
  local line = #lines
  lines[#lines + 1] = prefix .. content
  add_highlight(highlights, line, #prefix, -1, "DashboardText")

  local offset = #prefix
  for index, part in ipairs(parts) do
    add_highlight(highlights, line, offset, offset + 3, "DashboardKey")
    offset = offset + #part
    if index < #parts then
      offset = offset + 5
    end
  end
end

function M.render(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local winid = vim.fn.bufwinid(bufnr)
  if winid == -1 then
    return
  end

  local width = vim.api.nvim_win_get_width(winid)
  local height = vim.api.nvim_win_get_height(winid)
  local content = {}
  local highlights = {}

  add_logo_lines(content, highlights, width)
  content[#content + 1] = ""
  if width >= 58 then
    add_action_line(content, highlights, width, { actions[1], actions[2], actions[3] })
    add_action_line(content, highlights, width, { actions[4], actions[5], actions[6] })
    add_action_line(content, highlights, width, { actions[7] })
  else
    add_action_line(content, highlights, width, { actions[1], actions[2] })
    add_action_line(content, highlights, width, { actions[3], actions[4] })
    add_action_line(content, highlights, width, { actions[5], actions[6] })
    add_action_line(content, highlights, width, { actions[7] })
  end

  local top_padding = math.max(math.floor((height - #content) / 2), 1)
  local lines = {}
  for _ = 1, top_padding do
    lines[#lines + 1] = ""
  end
  vim.list_extend(lines, content)
  lines[#lines + 1] = ""

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  for _, highlight in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(
      bufnr,
      namespace,
      highlight.group,
      top_padding + highlight.line,
      highlight.first,
      highlight.last
    )
  end

  pcall(vim.api.nvim_win_set_cursor, winid, { #lines, 0 })
end

function M.open()
  local bufnr = vim.api.nvim_get_current_buf()
  local winid = vim.api.nvim_get_current_win()

  vim.api.nvim_buf_set_name(bufnr, "nvim-dashboard://start")
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false
  vim.bo[bufnr].filetype = "dashboard"

  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].cursorline = false
  vim.wo[winid].signcolumn = "no"
  vim.wo[winid].foldcolumn = "0"
  vim.wo[winid].list = false
  vim.wo[winid].colorcolumn = ""

  for _, action in ipairs(actions) do
    local command = action.command
    vim.keymap.set("n", action.key, function()
      vim.cmd(command)
      vim.schedule(function()
        M.render(bufnr)
      end)
    end, { buffer = bufnr, nowait = true, silent = true, desc = action.label })
  end

  vim.keymap.set("n", "i", function()
    vim.cmd.enew()
    vim.cmd.startinsert()
  end, { buffer = bufnr, nowait = true, silent = true, desc = "empty buffer in Insert mode" })

  M.render(bufnr)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("user_dashboard", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      if #vim.api.nvim_list_uis() == 0 or vim.fn.argc(-1) ~= 0 then
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_get_name(bufnr) ~= "" or vim.bo[bufnr].buftype ~= "" then
        return
      end

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      if #lines ~= 1 or lines[1] ~= "" then
        return
      end

      M.open()
    end,
  })

  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group,
    callback = function()
      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local bufnr = vim.api.nvim_win_get_buf(winid)
        if vim.bo[bufnr].filetype == "dashboard" then
          M.render(bufnr)
        end
      end
    end,
  })
end

return M
