return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      if vim.fn.executable("tree-sitter") == 1 then
        vim.cmd("TSUpdate")
      end
    end,
    dependencies = {
      "neovim-treesitter/treesitter-parser-registry",
    },
    config = function()
      local languages = {
        "asm",
        "bash",
        "c",
        "cpp",
        "css",
        "html",
        "javascript",
        "nasm",
        "python",
        "rust",
      }
      local filetypes = vim.list_extend(vim.deepcopy(languages), {
        "javascriptreact",
        "less",
        "scss",
        "sh",
        "typescriptreact",
      })

      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local function install_parsers()
        if vim.fn.executable("tree-sitter") ~= 1 then
          return
        end
        pcall(require("nvim-treesitter").install, languages)
      end

      install_parsers()

      local treesitter_group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = treesitter_group,
        pattern = "MasonToolsUpdateCompleted",
        callback = install_parsers,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = treesitter_group,
        pattern = filetypes,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
        end,
      })
    end,
  },
}
