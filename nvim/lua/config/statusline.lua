local M = {}

local modes = {
  n = { "NORMAL", "StatusModeNormal" },
  no = { "OP-PENDING", "StatusModeNormal" },
  nov = { "OP-PENDING", "StatusModeNormal" },
  noV = { "OP-PENDING", "StatusModeNormal" },
  ["no\22"] = { "OP-PENDING", "StatusModeNormal" },
  niI = { "NORMAL", "StatusModeNormal" },
  niR = { "NORMAL", "StatusModeNormal" },
  niV = { "NORMAL", "StatusModeNormal" },
  nt = { "NORMAL", "StatusModeNormal" },
  v = { "VISUAL", "StatusModeVisual" },
  V = { "V-LINE", "StatusModeVisual" },
  ["\22"] = { "V-BLOCK", "StatusModeVisual" },
  s = { "SELECT", "StatusModeVisual" },
  S = { "S-LINE", "StatusModeVisual" },
  ["\19"] = { "S-BLOCK", "StatusModeVisual" },
  i = { "INSERT", "StatusModeInsert" },
  ic = { "INSERT", "StatusModeInsert" },
  ix = { "INSERT", "StatusModeInsert" },
  R = { "REPLACE", "StatusModeReplace" },
  Rc = { "REPLACE", "StatusModeReplace" },
  Rx = { "REPLACE", "StatusModeReplace" },
  Rv = { "V-REPLACE", "StatusModeReplace" },
  Rvc = { "V-REPLACE", "StatusModeReplace" },
  Rvx = { "V-REPLACE", "StatusModeReplace" },
  c = { "COMMAND", "StatusModeCommand" },
  cv = { "EX", "StatusModeCommand" },
  ce = { "EX", "StatusModeCommand" },
  r = { "PROMPT", "StatusModeCommand" },
  rm = { "MORE", "StatusModeCommand" },
  ["r?"] = { "CONFIRM", "StatusModeCommand" },
  ["!"] = { "SHELL", "StatusModeTerminal" },
  t = { "TERMINAL", "StatusModeTerminal" },
}

local filetypes = {
  c = "C",
  cpp = "C++",
  rust = "Rust",
  asm = "ASM",
  nasm = "NASM",
  lua = "Lua",
  help = "Help",
}

local function escape(value)
  return value:gsub("%%", "%%%%")
end

local function get_window()
  local winid = tonumber(vim.g.statusline_winid)
  if not winid or not vim.api.nvim_win_is_valid(winid) then
    return vim.api.nvim_get_current_win()
  end
  return winid
end

local function filename(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype

  if name == "" then
    return "[No Name]"
  end

  if name:match("^vim%-practice://") then
    return "[Vim Practice]"
  end

  if name:match("^nvim%-dashboard://") then
    return "[Start]"
  end

  if buftype == "help" then
    return vim.fn.fnamemodify(name, ":t") .. " [help]"
  end

  return vim.fn.fnamemodify(name, ":~:.")
end

local function diagnostics(bufnr)
  local counts = vim.diagnostic.count(bufnr)
  local parts = {}

  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0
  local info = counts[vim.diagnostic.severity.INFO] or 0
  local hints = counts[vim.diagnostic.severity.HINT] or 0

  if errors > 0 then
    parts[#parts + 1] = "%#StatusDiagnosticError#E:" .. errors
  end
  if warnings > 0 then
    parts[#parts + 1] = "%#StatusDiagnosticWarn#W:" .. warnings
  end
  if info > 0 then
    parts[#parts + 1] = "%#StatusDiagnosticInfo#I:" .. info
  end
  if hints > 0 then
    parts[#parts + 1] = "%#StatusDiagnosticHint#H:" .. hints
  end

  if #parts == 0 then
    return ""
  end

  return table.concat(parts, " ") .. "%#StatusLine# "
end

local function lsp_clients(bufnr)
  local names = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    names[#names + 1] = client.name
  end

  if #names == 0 then
    return ""
  end

  table.sort(names)
  return "%#StatusLsp#" .. escape(table.concat(names, ",")) .. "%#StatusLine# "
end

function M.render()
  local winid = get_window()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local name = escape(filename(bufnr))

  if vim.bo[bufnr].filetype == "dashboard" then
    local group = winid == vim.api.nvim_get_current_win() and "StatusLine" or "StatusLineNC"
    return "%#" .. group .. "# [Start] "
  end

  if winid ~= vim.api.nvim_get_current_win() then
    return "%#StatusLineNC# " .. name .. " %=%l:%c "
  end

  local mode = modes[vim.api.nvim_get_mode().mode] or { "UNKNOWN", "StatusModeCommand" }
  local modified = vim.bo[bufnr].modified and "%#StatusModified# [+]" or ""
  local readonly = (vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable)
      and "%#StatusReadonly# [RO]"
    or ""
  local filetype = vim.bo[bufnr].filetype
  local language = filetypes[filetype] or filetype

  local left = table.concat({
    "%#" .. mode[2] .. "# " .. mode[1] .. " ",
    "%#StatusLine# %<" .. name,
    modified,
    readonly,
    " ",
  })

  local right = diagnostics(bufnr)
    .. lsp_clients(bufnr)
    .. (language ~= "" and ("%#StatusFiletype#" .. escape(language) .. "%#StatusLine# ") or "")
    .. "%l:%c %p%% "

  return left .. "%=" .. right
end

function M.setup()
  _G.CaelestiaStatusline = M.render
  vim.o.statusline = "%!v:lua.CaelestiaStatusline()"

  local group = vim.api.nvim_create_augroup("user_statusline", { clear = true })
  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach", "ModeChanged" }, {
    group = group,
    callback = function()
      vim.cmd.redrawstatus()
    end,
  })
end

return M
