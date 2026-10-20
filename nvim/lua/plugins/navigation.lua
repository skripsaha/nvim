return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Find text",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags()
        end,
        desc = "Search help",
      },
    },
    opts = {
      winopts = {
        border = "single",
        preview = {
          border = "single",
        },
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      view = {
        width = 32,
        side = "left",
        signcolumn = "no",
        preserve_window_proportions = true,
      },
      renderer = {
        group_empty = true,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "`",
            edge = "|",
            item = "|",
            bottom = "-",
            none = " ",
          },
        },
        icons = {
          web_devicons = {
            file = { enable = false, color = false },
            folder = { enable = false, color = false },
          },
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = false,
            modified = false,
            hidden = false,
            diagnostics = false,
            bookmarks = false,
          },
          glyphs = {
            folder = {
              arrow_closed = ">",
              arrow_open = "v",
            },
          },
        },
      },
      diagnostics = {
        enable = false,
      },
      git = {
        enable = false,
      },
      filters = {
        dotfiles = false,
      },
    },
  },
}
