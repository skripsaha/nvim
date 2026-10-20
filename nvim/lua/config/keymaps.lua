local map = vim.keymap.set

-- Build navigation habits around Vim motions instead of arrow keys.
for _, key in ipairs({ "<Left>", "<Down>", "<Up>", "<Right>" }) do
  map({ "n", "x", "o", "i" }, key, "<Nop>", { desc = "Arrow key disabled" })
end

-- Escape also clears the previous search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between windows without entering the <C-w> prefix first.
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Keep selected text selected while changing its indentation.
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- A small, memorable set of general commands.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>h", "<cmd>VimGuide<CR>", { desc = "Open Vim guide" })
map("n", "<leader>p", "<cmd>VimPractice<CR>", { desc = "Open practice buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>ba", "<C-^>", { desc = "Alternate buffer" })
map("n", "<leader>bd", "<cmd>confirm bdelete<CR>", { desc = "Close buffer" })

local function close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  local closed = 0
  local modified = 0

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if bufnr ~= current and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
      if vim.bo[bufnr].modified then
        modified = modified + 1
      elseif pcall(vim.api.nvim_buf_delete, bufnr, { force = false }) then
        closed = closed + 1
      end
    end
  end

  local message = ("Closed %d other buffer%s"):format(closed, closed == 1 and "" or "s")
  if modified > 0 then
    message = message .. ("; kept %d modified"):format(modified)
  end
  vim.notify(message)
end

map("n", "<leader>bo", close_other_buffers, { desc = "Close other buffers" })

-- Diagnostic navigation uses the current Neovim API.
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Explain diagnostic" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "List diagnostics" })

vim.api.nvim_create_user_command("VimGuide", function()
  vim.cmd.help("vim-guide")
end, { desc = "Open the practical Vim guide" })

vim.api.nvim_create_user_command("VimPractice", function()
  require("config.practice").open()
end, { desc = "Open a disposable Vim practice buffer" })
