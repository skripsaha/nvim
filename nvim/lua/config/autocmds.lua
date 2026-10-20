local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Keep indentation stable even when a filetype plugin changes buffer-local defaults.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "*",
  desc = "Use four spaces for indentation",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Briefly show copied text, which makes yank operations easier to learn.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Return to the last edited position when reopening a regular file.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Restore the last cursor position",
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
