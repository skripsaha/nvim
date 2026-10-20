local CppStyle = require("config.cpp_style")

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufEnter", "BufWritePost", "InsertLeave" },
    cmd = { "Lint", "LintInfo" },
    keys = {
      {
        "<leader>cl",
        function()
          vim.cmd("Lint")
        end,
        desc = "Lint current buffer",
      },
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        objc = { "clangtidy" },
        objcpp = { "clangtidy" },
      }

      -- Run the complete clang-tidy check set and keep the requested naming rules.
      local clang_tidy = CppStyle.ClangTidyExecutable()
      if clang_tidy then
        lint.linters.clangtidy.cmd = clang_tidy
      end
      lint.linters.clangtidy.args = {
        "--quiet",
        "--checks=*",
        "--config=" .. CppStyle.NamingConfig(),
        function()
          local standard = vim.bo.filetype == "c" and "-std=c23" or "-std=c++2c"
          return "--extra-arg-before=" .. standard
        end,
      }

      local lint_group = vim.api.nvim_create_augroup("user_lint", { clear = true })
      local function run_linter()
        if vim.bo.modifiable and CppStyle.IsCppFiletype(vim.bo.filetype) then
          lint.try_lint("clangtidy")
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = run_linter,
      })

      vim.api.nvim_create_user_command("Lint", function()
        if not CppStyle.ClangTidyExecutable() then
          vim.notify("clang-tidy is not installed or is not in PATH", vim.log.levels.WARN)
          return
        end
        lint.try_lint("clangtidy")
      end, { desc = "Run clang-tidy on the current buffer" })

      vim.api.nvim_create_user_command("LintInfo", function()
        vim.notify("clang-tidy: " .. (CppStyle.ClangTidyExecutable() and "available" or "missing"))
      end, { desc = "Show clang-tidy availability" })
    end,
  },
}
