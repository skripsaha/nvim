local M = {}

local state_home = vim.env.XDG_STATE_HOME
  or vim.fs.joinpath(vim.env.HOME, ".local", "state")

local palette_path = vim.fs.joinpath(state_home, "caelestia", "theme", "nvim")
local palette_dir = vim.fs.dirname(palette_path)

local fallback = {
  bg = "#101010",
  fg = "#d0d0c8",
  alt_bg = "#181818",
  primary = "#9b8ab8",
  on_primary = "#17131d",
  primary_container = "#393043",
  on_primary_container = "#e3d9ec",
  primary_dim = "#86769f",
  secondary = "#9eafa0",
  secondary_container = "#29332b",
  tertiary = "#c0a878",
  tertiary_container = "#423824",
  error = "#cf7777",
  error_container = "#472525",
  surface = "#181818",
  surface_tint = "#9b8ab8",
  outline = "#777771",
  outline_variant = "#3f3f3b",
  on_surface = "#d0d0c8",
  on_surface_variant = "#9a9a92",
  inverse_primary = "#625477",
  mode = "dark",
}

local required = {
  "bg",
  "fg",
  "alt_bg",
  "primary",
  "on_primary",
  "primary_container",
  "on_primary_container",
  "primary_dim",
  "secondary",
  "secondary_container",
  "tertiary",
  "tertiary_container",
  "error",
  "error_container",
  "surface",
  "outline",
  "outline_variant",
  "on_surface",
  "on_surface_variant",
}

local function load_palette()
  local ok, palette = pcall(dofile, palette_path)
  if not ok or type(palette) ~= "table" then
    return fallback, false
  end

  for _, key in ipairs(required) do
    if type(palette[key]) ~= "string" then
      return fallback, false
    end
  end

  return palette, true
end

local function set(name, value)
  vim.api.nvim_set_hl(0, name, value)
end

local function link(name, target)
  set(name, { link = target })
end

function M.apply()
  local p, from_caelestia = load_palette()

  vim.o.termguicolors = true
  vim.o.background = p.mode == "light" and "light" or "dark"

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "caelestia"
  vim.g.caelestia_palette_source = from_caelestia and palette_path or "fallback"

  -- Editor surfaces. The main background stays transparent so the terminal
  -- remains visually continuous with the rest of the Caelestia session.
  set("Normal", { fg = p.on_surface, bg = "NONE" })
  set("NormalNC", { fg = p.on_surface, bg = "NONE" })
  set("NormalFloat", { fg = p.on_surface, bg = p.surface })
  set("FloatBorder", { fg = p.outline, bg = p.surface })
  set("FloatTitle", { fg = p.primary, bg = p.surface, bold = true })
  set("EndOfBuffer", { fg = p.bg, bg = "NONE" })
  set("SignColumn", { fg = p.outline, bg = "NONE" })
  set("FoldColumn", { fg = p.outline, bg = "NONE" })
  set("LineNr", { fg = p.outline_variant, bg = "NONE" })
  set("LineNrAbove", { fg = p.outline_variant, bg = "NONE" })
  set("LineNrBelow", { fg = p.outline_variant, bg = "NONE" })
  set("CursorLine", { bg = p.alt_bg })
  set("CursorLineNr", { fg = p.primary, bg = p.alt_bg, bold = true })
  set("CursorColumn", { bg = p.alt_bg })
  set("ColorColumn", { bg = p.alt_bg })
  set("WinSeparator", { fg = p.outline_variant, bg = "NONE" })
  set("VertSplit", { fg = p.outline_variant, bg = "NONE" })
  set("MsgSeparator", { fg = p.outline_variant, bg = p.alt_bg })
  set("Folded", { fg = p.on_surface_variant, bg = p.alt_bg })
  set("NonText", { fg = p.outline_variant })
  set("Whitespace", { fg = p.outline_variant })
  set("SpecialKey", { fg = p.outline })
  set("Conceal", { fg = p.outline })

  -- Selection, search, and completion.
  set("Visual", { fg = p.on_primary_container, bg = p.primary_container })
  set("VisualNOS", { fg = p.on_primary_container, bg = p.primary_container })
  set("Search", { fg = p.on_primary, bg = p.primary })
  set("IncSearch", { fg = p.bg, bg = p.tertiary, bold = true })
  set("CurSearch", { fg = p.bg, bg = p.tertiary, bold = true })
  set("Substitute", { fg = p.bg, bg = p.tertiary })
  set("MatchParen", { fg = p.primary, bg = p.primary_container, bold = true })
  set("Pmenu", { fg = p.on_surface, bg = p.surface })
  set("PmenuSel", { fg = p.on_primary_container, bg = p.primary_container, bold = true })
  set("PmenuSbar", { bg = p.alt_bg })
  set("PmenuThumb", { bg = p.outline })
  link("WildMenu", "PmenuSel")

  -- Native interface elements.
  set("StatusLine", { fg = p.on_surface, bg = p.surface })
  set("StatusLineNC", { fg = p.outline, bg = p.alt_bg })
  set("StatusModeNormal", { fg = p.on_primary, bg = p.primary, bold = true })
  set("StatusModeInsert", { fg = p.bg, bg = p.secondary, bold = true })
  set("StatusModeVisual", { fg = p.bg, bg = p.tertiary, bold = true })
  set("StatusModeReplace", { fg = p.bg, bg = p.error, bold = true })
  set("StatusModeCommand", { fg = p.on_primary_container, bg = p.primary_container, bold = true })
  set("StatusModeTerminal", { fg = p.on_surface, bg = p.outline_variant, bold = true })
  set("StatusModified", { fg = p.tertiary, bg = p.surface, bold = true })
  set("StatusReadonly", { fg = p.error, bg = p.surface, bold = true })
  set("StatusDiagnosticError", { fg = p.error, bg = p.surface, bold = true })
  set("StatusDiagnosticWarn", { fg = p.tertiary, bg = p.surface, bold = true })
  set("StatusDiagnosticInfo", { fg = p.secondary, bg = p.surface })
  set("StatusDiagnosticHint", { fg = p.on_surface_variant, bg = p.surface })
  set("StatusLsp", { fg = p.primary, bg = p.surface })
  set("StatusFiletype", { fg = p.on_surface_variant, bg = p.surface })
  set("TabLine", { fg = p.on_surface_variant, bg = p.surface })
  set("TabLineFill", { fg = p.outline_variant, bg = p.alt_bg })
  set("TabLineSel", { fg = p.on_primary, bg = p.primary, bold = true })
  set("Directory", { fg = p.primary })
  set("Title", { fg = p.primary, bold = true })
  set("Question", { fg = p.secondary })
  set("MoreMsg", { fg = p.secondary })
  set("ModeMsg", { fg = p.primary, bold = true })
  set("WarningMsg", { fg = p.tertiary })
  set("ErrorMsg", { fg = p.error, bold = true })
  set("QuickFixLine", { fg = p.on_primary_container, bg = p.primary_container })
  set("DashboardVimLetter", { fg = "#cccccc", bold = true })
  set("DashboardVimDiamond", { fg = "#009933", bold = true })
  set("DashboardVimText", { fg = "#cccccc", bold = true })
  set("DashboardVimBright", { fg = "#ffffff", bold = true })
  set("DashboardKey", { fg = p.primary, bold = true })
  set("DashboardText", { fg = p.on_surface_variant })

  -- Vim syntax groups. Tree-sitter and LSP semantic groups link to these below.
  set("Comment", { fg = p.outline })
  set("Constant", { fg = p.tertiary })
  set("String", { fg = p.secondary })
  set("Character", { fg = p.secondary })
  set("Number", { fg = p.tertiary })
  set("Boolean", { fg = p.tertiary, bold = true })
  set("Float", { fg = p.tertiary })
  set("Identifier", { fg = p.on_surface })
  set("Function", { fg = p.primary })
  set("Statement", { fg = p.primary_dim, bold = true })
  set("Conditional", { fg = p.primary_dim })
  set("Repeat", { fg = p.primary_dim })
  set("Label", { fg = p.secondary })
  set("Operator", { fg = p.on_surface_variant })
  set("Keyword", { fg = p.primary_dim })
  set("Exception", { fg = p.error })
  set("PreProc", { fg = p.secondary })
  set("Include", { fg = p.primary_dim })
  set("Define", { fg = p.secondary })
  set("Macro", { fg = p.secondary })
  set("PreCondit", { fg = p.secondary })
  set("Type", { fg = p.tertiary })
  set("StorageClass", { fg = p.primary_dim })
  set("Structure", { fg = p.tertiary })
  set("Typedef", { fg = p.tertiary })
  set("Special", { fg = p.tertiary })
  set("SpecialChar", { fg = p.tertiary })
  set("Tag", { fg = p.primary })
  set("Delimiter", { fg = p.on_surface_variant })
  set("SpecialComment", { fg = p.outline })
  set("Debug", { fg = p.error })
  set("Underlined", { fg = p.primary, underline = true })
  set("Ignore", { fg = p.outline_variant })
  set("Error", { fg = p.error, bg = p.error_container })
  set("Todo", { fg = p.secondary, bg = p.secondary_container, bold = true })

  -- Diagnostics are visible without painting entire lines.
  set("DiagnosticError", { fg = p.error })
  set("DiagnosticWarn", { fg = p.tertiary })
  set("DiagnosticInfo", { fg = p.secondary })
  set("DiagnosticHint", { fg = p.on_surface_variant })
  set("DiagnosticOk", { fg = p.secondary })
  set("DiagnosticUnderlineError", { undercurl = true, sp = p.error })
  set("DiagnosticUnderlineWarn", { undercurl = true, sp = p.tertiary })
  set("DiagnosticUnderlineInfo", { undercurl = true, sp = p.secondary })
  set("DiagnosticUnderlineHint", { undercurl = true, sp = p.on_surface_variant })
  link("LspReferenceText", "Visual")
  link("LspReferenceRead", "Visual")
  link("LspReferenceWrite", "Visual")
  link("LspSignatureActiveParameter", "IncSearch")

  -- Diff colours stay subdued and use semantic Caelestia containers.
  set("DiffAdd", { fg = p.secondary, bg = p.secondary_container })
  set("DiffChange", { fg = p.primary, bg = p.primary_container })
  set("DiffDelete", { fg = p.error, bg = p.error_container })
  set("DiffText", { fg = p.on_primary, bg = p.primary, bold = true })
  set("Added", { fg = p.secondary })
  set("Changed", { fg = p.primary })
  set("Removed", { fg = p.error })

  -- Tree-sitter and semantic-token links keep the palette intentionally small.
  link("@comment", "Comment")
  link("@comment.documentation", "Comment")
  link("@constant", "Constant")
  link("@constant.builtin", "Constant")
  link("@string", "String")
  link("@string.escape", "SpecialChar")
  link("@character", "Character")
  link("@number", "Number")
  link("@boolean", "Boolean")
  link("@variable", "Identifier")
  link("@variable.builtin", "Special")
  link("@variable.parameter", "Identifier")
  link("@function", "Function")
  link("@function.call", "Function")
  link("@function.builtin", "Special")
  link("@function.macro", "Macro")
  link("@keyword", "Keyword")
  link("@keyword.function", "Keyword")
  link("@keyword.return", "Keyword")
  link("@keyword.conditional", "Conditional")
  link("@keyword.repeat", "Repeat")
  link("@operator", "Operator")
  link("@type", "Type")
  link("@type.builtin", "Type")
  link("@property", "Identifier")
  link("@attribute", "PreProc")
  link("@constructor", "Type")
  link("@punctuation.delimiter", "Delimiter")
  link("@punctuation.bracket", "Delimiter")
  link("@markup.heading", "Title")
  link("@markup.link", "Underlined")
  link("@markup.raw", "String")

  -- Plugin surfaces use the same restrained native palette.
  link("NvimTreeNormal", "Normal")
  link("NvimTreeNormalNC", "Normal")
  link("NvimTreeEndOfBuffer", "EndOfBuffer")
  link("NvimTreeWinSeparator", "WinSeparator")
  set("NvimTreeRootFolder", { fg = p.primary, bold = true })
  set("NvimTreeFolderName", { fg = p.on_surface })
  set("NvimTreeOpenedFolderName", { fg = p.primary })
  set("NvimTreeIndentMarker", { fg = p.outline_variant })
  set("NvimTreeSpecialFile", { fg = p.tertiary })

  link("FzfLuaNormal", "NormalFloat")
  link("FzfLuaBorder", "FloatBorder")
  link("FzfLuaTitle", "FloatTitle")
  set("FzfLuaPointer", { fg = p.primary, bold = true })
  set("FzfLuaMarker", { fg = p.secondary })
  set("FzfLuaMatch", { fg = p.primary, bold = true })

  set("WhichKey", { fg = p.primary })
  set("WhichKeyGroup", { fg = p.secondary })
  set("WhichKeyDesc", { fg = p.on_surface })
  set("WhichKeySeparator", { fg = p.outline_variant })
  link("WhichKeyNormal", "NormalFloat")
  link("WhichKeyBorder", "FloatBorder")
end

local function start_watcher()
  if M.watcher or not vim.uv.fs_stat(palette_dir) then
    return
  end

  local watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end

  local ok = watcher:start(palette_dir, {}, function(error, filename)
    if error or (filename and filename ~= "nvim") then
      return
    end

    vim.schedule(function()
      if vim.g.colors_name == "caelestia" then
        M.apply()
        vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "caelestia" })
      end
    end)
  end)

  if ok then
    M.watcher = watcher
  else
    watcher:close()
  end
end

function M.setup()
  vim.cmd.colorscheme("caelestia")
  start_watcher()

  vim.api.nvim_create_user_command("CaelestiaReload", function()
    M.apply()
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "caelestia" })
  end, { desc = "Reload colours from the current Caelestia scheme" })
end

return M
