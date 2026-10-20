local CppStyle = require("config.cpp_style")
local Completion = require("config.completion")

local function FormatNames(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    vim.notify("Format applied; save the buffer to enable naming fixes", vim.log.levels.INFO)
    return
  end

  local clang_tidy = CppStyle.ClangTidyExecutable()
  if not clang_tidy then
    vim.notify("Format applied; clang-tidy is unavailable, so naming fixes were skipped", vim.log.levels.WARN)
    return
  end

  local saved, save_error = pcall(vim.cmd, "silent update")
  if not saved then
    vim.notify("Format naming pass could not save the buffer: " .. save_error, vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(filename, { "compile_commands.json", "compile_flags.txt", ".git" })
    or vim.fs.dirname(filename)
  local standard = vim.bo[bufnr].filetype == "c" and "-std=c23" or "-std=c++2c"
  local config = CppStyle.NamingConfig()
  local command = {
    clang_tidy,
    "--quiet",
    "--fix",
    "--checks=-*,readability-identifier-naming",
    "--config=" .. config,
    filename,
    "--",
    standard,
  }

  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Format naming pass failed: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
        return
      end

      if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent checktime")
        end)
      end
      vim.notify("Format and naming conventions applied")
    end)
  end)
end

local function FormatBuffer(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if CppStyle.IsCppFiletype(filetype) and not CppStyle.ClangFormatExecutable() then
    vim.notify("Format: clang-format is unavailable; install it through Mason (:MasonToolsInstall)", vim.log.levels.WARN)
    return
  end

  local conform = require("conform")
  conform.format({
    bufnr = bufnr,
    async = true,
    formatters = CppStyle.IsCppFiletype(filetype) and { "clang_format" } or nil,
    lsp_format = "never",
  }, function(err)
    if err then
      vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
      return
    end
    if CppStyle.IsCppFiletype(filetype) then
      FormatNames(bufnr)
    end
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
        signs = false,
        float = {
          border = "single",
          source = true,
          header = "",
          prefix = "",
        },
      })

      local lsp_group = vim.api.nvim_create_augroup("user_lsp", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_group,
        desc = "Configure buffer-local LSP mappings",
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("grr", vim.lsp.buf.references, "List references")
          map("K", vim.lsp.buf.hover, "Show documentation")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")

          if client and client:supports_method("textDocument/completion") then
            Completion.ConfigureBuffer(event.buf)
            vim.keymap.set("i", "<Tab>", Completion.Tab, {
              buffer = event.buf,
              desc = "Complete common LSP prefix",
            })
          end
        end,
      })

      local servers = {
        asm_lsp = {
          executable = "asm-lsp",
          filetypes = { "asm", "nasm", "vmasm" },
          root_dir = function(bufnr, on_dir)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            on_dir(
              vim.fs.root(filename, { ".asm-lsp.toml", "Makefile", ".git" })
                or vim.fs.dirname(filename)
            )
          end,
        },
        bashls = { executable = "bash-language-server" },
        basedpyright = { executable = "basedpyright-langserver" },
        clangd_c = {
          executable = "clangd",
          filetypes = { "c", "objc" },
          init_options = {
            fallbackFlags = { "-std=c23" },
          },
        },
        clangd_cpp = {
          executable = "clangd",
          filetypes = { "cpp", "objcpp", "cuda" },
          cmd = {
            "clangd",
            "--background-index",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
          },
          init_options = {
            -- `c++2c` is Clang's portable spelling for the C++26 draft mode.
            -- A project's compile_commands.json/.clangd still takes priority.
            fallbackFlags = { "-std=c++2c" },
          },
        },
        cssls = { executable = "vscode-css-language-server" },
        html = { executable = "vscode-html-language-server" },
        ruff = { executable = "ruff" },
        rust_analyzer = { executable = "rust-analyzer" },
        ts_ls = { executable = "typescript-language-server" },
      }

      for server, options in pairs(servers) do
        local config = vim.deepcopy(options)
        config.executable = nil
        if vim.startswith(server, "clangd_") then
          local clangd_defaults = vim.deepcopy(vim.lsp.config["clangd"])
          config = vim.tbl_deep_extend("force", clangd_defaults, config)
        end
        vim.lsp.config(server, config)
      end

      local function enable_servers()
        for server, options in pairs(servers) do
          if vim.fn.executable(options.executable) == 1 then
            vim.lsp.enable(server)
          end
        end
      end

      enable_servers()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        group = lsp_group,
        callback = enable_servers,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          FormatBuffer(vim.api.nvim_get_current_buf())
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters = {
        clang_format = {
          command = CppStyle.ClangFormatExecutable() or "clang-format",
          prepend_args = { "--style=" .. CppStyle.FormatStyle },
        },
        prettier = {
          prepend_args = { "--tab-width", "4", "--use-tabs", "false" },
        },
        rustfmt = {
          prepend_args = { "--config", "hard_tabs=false", "--config", "tab_spaces=4" },
        },
        shfmt = {
          prepend_args = { "-i", "4" },
        },
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        end

        return {
          timeout_ms = 1000,
          lsp_format = "never",
        }
      end,
      notify_on_error = true,
      notify_no_formatters = false,
    },
    init = function()
      vim.api.nvim_create_user_command("Format", function()
        FormatBuffer(vim.api.nvim_get_current_buf())
      end, {
        desc = "Format buffer with C/C++ style and naming rules",
      })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
          vim.notify("Autoformat disabled for this buffer")
        else
          vim.g.disable_autoformat = true
          vim.notify("Autoformat disabled globally")
        end
      end, {
        desc = "Disable autoformat (use ! for current buffer)",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        vim.notify("Autoformat enabled")
      end, { desc = "Enable autoformat" })
    end,
  },
}
