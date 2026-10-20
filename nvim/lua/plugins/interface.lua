return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      delay = 500,
      icons = {
        mappings = false,
        breadcrumb = ">",
        separator = "->",
        group = "+",
        ellipsis = "...",
      },
      win = {
        border = "single",
        title = false,
      },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = true })
        end,
        desc = "Show keymap help",
      },
    },
  },
}
