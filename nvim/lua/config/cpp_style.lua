local CppStyle = {}

CppStyle.Filetypes = { "c", "cpp", "objc", "objcpp" }
CppStyle.FormatStyle = table.concat({
  "{BasedOnStyle: LLVM",
  "BreakBeforeBraces: Attach",
  "IndentWidth: 4",
  "TabWidth: 4",
  "UseTab: Never",
  "AllowShortFunctionsOnASingleLine: All",
  "AllowShortIfStatementsOnASingleLine: Never",
  "AllowShortLoopsOnASingleLine: false",
  "AllowShortBlocksOnASingleLine: Empty",
  "}",
}, ", ")

CppStyle.NamingCases = {
  ["readability-identifier-naming.DefaultCase"] = "lower_case",
  ["readability-identifier-naming.VariableCase"] = "lower_case",
  ["readability-identifier-naming.LocalVariableCase"] = "lower_case",
  ["readability-identifier-naming.GlobalVariableCase"] = "lower_case",
  ["readability-identifier-naming.StaticVariableCase"] = "lower_case",
  ["readability-identifier-naming.MemberCase"] = "lower_case",
  ["readability-identifier-naming.ClassMemberCase"] = "lower_case",
  ["readability-identifier-naming.ParameterCase"] = "lower_case",
  ["readability-identifier-naming.FunctionCase"] = "camelBack",
  ["readability-identifier-naming.MethodCase"] = "camelBack",
  ["readability-identifier-naming.ClassMethodCase"] = "camelBack",
  ["readability-identifier-naming.PublicMethodCase"] = "camelBack",
  ["readability-identifier-naming.ConstexprFunctionCase"] = "camelBack",
  ["readability-identifier-naming.ClassCase"] = "CamelCase",
  ["readability-identifier-naming.StructCase"] = "CamelCase",
  ["readability-identifier-naming.UnionCase"] = "CamelCase",
  ["readability-identifier-naming.TypedefCase"] = "CamelCase",
  ["readability-identifier-naming.TypeAliasCase"] = "CamelCase",
  ["readability-identifier-naming.ConceptCase"] = "CamelCase",
  ["readability-identifier-naming.TemplateParameterCase"] = "CamelCase",
  ["readability-identifier-naming.EnumCase"] = "UPPER_CASE",
  ["readability-identifier-naming.EnumConstantCase"] = "UPPER_CASE",
  ["readability-identifier-naming.ScopedEnumConstantCase"] = "UPPER_CASE",
  ["readability-identifier-naming.MacroDefinitionCase"] = "UPPER_CASE",
  ["readability-identifier-naming.ConstexprVariableCase"] = "UPPER_CASE",
  ["readability-identifier-naming.GlobalConstexprVariableCase"] = "UPPER_CASE",
  ["readability-identifier-naming.StaticConstexprVariableCase"] = "UPPER_CASE",
  ["readability-identifier-naming.ClassConstexprCase"] = "UPPER_CASE",
  ["readability-identifier-naming.ConstantCase"] = "UPPER_CASE",
  ["readability-identifier-naming.GlobalConstantCase"] = "UPPER_CASE",
  ["readability-identifier-naming.ClassConstantCase"] = "UPPER_CASE",
}

function CppStyle.IsCppFiletype(filetype)
  return vim.tbl_contains(CppStyle.Filetypes, filetype)
end

function CppStyle.NamingConfig()
  return vim.json.encode({
    Checks = "-*,readability-identifier-naming",
    FormatStyle = "none",
    CheckOptions = CppStyle.NamingCases,
  })
end

function CppStyle.ClangTidyExecutable()
  for _, executable in ipairs({
    "clang-tidy",
    "/opt/homebrew/opt/llvm/bin/clang-tidy",
    "/usr/local/opt/llvm/bin/clang-tidy",
  }) do
    if vim.fn.executable(executable) == 1 then
      return executable
    end
  end
end

function CppStyle.ClangFormatExecutable()
  for _, executable in ipairs({
    "clang-format",
    "/opt/homebrew/opt/llvm/bin/clang-format",
    "/usr/local/opt/llvm/bin/clang-format",
  }) do
    if vim.fn.executable(executable) == 1 then
      return executable
    end
  end
end

return CppStyle
