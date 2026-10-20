local opt = vim.opt

-- Keep the interface quiet, but retain the information useful while learning.
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "no"
opt.showmode = false
opt.laststatus = 2
opt.ruler = false
opt.cmdheight = 1

-- One restrained TUI language for native windows, splits and pop-up menus.
-- ASCII separators also stay readable in a plain console without a patched font.
opt.winborder = "single"
opt.winblend = 0
opt.pumblend = 0
opt.pumheight = 8
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.shortmess:append("I")
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "-",
  foldclose = "+",
  foldsep = "|",
  diff = "/",
  msgsep = "-",
  horiz = "-",
  horizup = "+",
  horizdown = "+",
  vert = "|",
  vertleft = "+",
  vertright = "+",
  verthoriz = "+",
}

-- Editing defaults. The FileType autocmd reapplies these values per buffer.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true
opt.wrap = false
opt.showbreak = "> "

-- Hidden characters are available when needed, but do not create visual noise
-- during ordinary editing. A key to toggle them can be added when we need it.
opt.list = false
opt.listchars = {
  tab = "> ",
  trail = ".",
  nbsp = "+",
  extends = ">",
  precedes = "<",
}

-- Searching stays incremental and case-aware.
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Predictable splits and enough context around the cursor.
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 5
opt.sidescrolloff = 5

-- Reliability matters more than shaving a few bytes from disk.
opt.undofile = true
opt.swapfile = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 500

-- Keyboard-first means keyboard-only inside Neovim.
opt.mouse = ""

-- Make Normal-mode commands work while the OS keyboard layout is Russian.
-- Insert mode is unaffected, so Russian text can still be entered normally.
opt.langmap = table.concat({
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz",
}, ",")
