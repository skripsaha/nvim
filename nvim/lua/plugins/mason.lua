return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {
      PATH = "prepend",
      ui = {
        border = "single",
      },
    },
    dependencies = {
      "neovim/nvim-lspconfig",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function(_, opts)
      require("mason").setup(opts)

      require("mason-tool-installer").setup({
        ensure_installed = {
          "asm-lsp",
          "bash-language-server",
          "basedpyright",
          "clangd",
          "clang-format",
          "css-lsp",
          "html-lsp",
          "prettier",
          "ruff",
          "rust-analyzer",
          "rustfmt",
          "shfmt",
          "shellcheck",
          "typescript-language-server",
          "tree-sitter-cli",
        },
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 24,
      })
    end,
  },
}
