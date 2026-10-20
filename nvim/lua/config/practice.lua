local M = {}

local original_text = {
  "VIM PRACTICE BUFFER",
  "===================",
  "",
  "This is a disposable playground. Change, delete, copy, and rearrange anything.",
  "Close this tab with :q. Open it again with <Space>p to get a clean copy.",
  "Open the guide with <Space>h when you need a hint.",
  "",
  "--------------------------------------------------------------------------",
  "1. BASIC MOTIONS: h j k l, w b e, 0 ^ $",
  "--------------------------------------------------------------------------",
  "",
  "Move through these short words without using arrow keys:",
  "alpha beta gamma delta epsilon zeta eta theta",
  "",
  "Move between punctuation and WORDS:",
  "first.item -> second_item -> THIRD-ITEM -> final.item",
  "",
  "Try 0, ^, and $ on the indented line below:",
  "            the useful text begins here and ends there",
  "",
  "--------------------------------------------------------------------------",
  "2. FIND ON A LINE: f F t T ; ,",
  "--------------------------------------------------------------------------",
  "",
  "Jump to each x with fx, then repeat with ; and go back with ,:",
  "start x one x two x three x finish",
  "",
  "Use f( and then % to jump between matching parentheses:",
  "result = calculate(alpha, nested(beta, gamma), delta);",
  "",
  "--------------------------------------------------------------------------",
  "3. OPERATORS AND TEXT OBJECTS: d c y + motion/object",
  "--------------------------------------------------------------------------",
  "",
  "Place the cursor on CHANGE_ME and try ciw:",
  "The variable CHANGE_ME contains an unfortunate name.",
  "",
  "Try ci\" inside the quotes and ci( inside the parentheses:",
  "message = \"replace only this text\";",
  "value = function(change, these, arguments);",
  "",
  "Try diw, daw, dw, d$, and then undo each experiment with u:",
  "one two three four five six seven eight",
  "",
  "Try r<char> on the deliberate typo:",
  "The kernal starts successfully.",
  "",
  "--------------------------------------------------------------------------",
  "4. COUNTS AND REPEAT: 3w, 2dd, .",
  "--------------------------------------------------------------------------",
  "",
  "Use 4w to jump between groups:",
  "zero one two three four five six seven eight nine",
  "",
  "Change red to blue with ciw, find the next red with n, then press .:",
  "red green red yellow red purple red orange",
  "",
  "Delete two lines at once with 2dd, then restore them with u:",
  "temporary line A",
  "temporary line B",
  "permanent line C",
  "",
  "--------------------------------------------------------------------------",
  "5. SEARCH AND REPLACE: /, n, N, *, :substitute",
  "--------------------------------------------------------------------------",
  "",
  "Search for TARGET with /TARGET and move through matches with n and N:",
  "TARGET alpha beta TARGET gamma delta TARGET epsilon TARGET",
  "",
  "Try :%s/banana/orange/gc and answer each confirmation:",
  "banana apple banana pear banana grape banana",
  "",
  "Place the cursor on kernel and use * and #:",
  "kernel module kernel driver kernel scheduler kernel memory",
  "",
  "--------------------------------------------------------------------------",
  "6. VISUAL MODE: v, V, CTRL-V",
  "--------------------------------------------------------------------------",
  "",
  "Select individual words with v, then try y, d, c, >, <, and ~.",
  "select these words and freely transform them",
  "",
  "Use CTRL-V for a rectangular block in this table:",
  "001  alpha    enabled",
  "002  beta     enabled",
  "003  gamma    enabled",
  "004  delta    enabled",
  "",
  "--------------------------------------------------------------------------",
  "7. YANK, DELETE, AND PUT: y d p P",
  "--------------------------------------------------------------------------",
  "",
  "Copy this line with yy and paste it below with p.",
  "Move this line somewhere else using dd followed by p.",
  "Experiment with yiw, y$, \"0p, and :registers on these words.",
  "",
  "shopping list:",
  "- compiler",
  "- linker",
  "- debugger",
  "- emulator",
  "",
  "--------------------------------------------------------------------------",
  "8. CODE PRACTICE: %, =, ci{, search, LSP motions",
  "--------------------------------------------------------------------------",
  "",
  "int sum(const int *values, int count) {",
  "int result = 0;",
  "for (int index = 0; index < count; ++index) {",
  "result += values[index];",
  "}",
  "return result;",
  "}",
  "",
  "Try these exercises:",
  "- Jump between braces with %.",
  "- Select the function with V and motions.",
  "- Fix indentation with = followed by a motion or selection.",
  "- Rename result manually using * followed by ciw and repetitions of n and .",
  "",
  "--------------------------------------------------------------------------",
  "9. MARKS AND MACROS: m, ', `, q, @",
  "--------------------------------------------------------------------------",
  "",
  "Set mark a here with ma, move away, then return with `a.",
  "",
  "Record a macro that changes item to entry, then run it with @a:",
  "item = alpha",
  "item = beta",
  "item = gamma",
  "item = delta",
  "",
  "--------------------------------------------------------------------------",
  "10. FREE AREA",
  "--------------------------------------------------------------------------",
  "",
  "Write anything below. Nothing in this buffer is permanent.",
  "",
  "",
  "",
}

function M.open()
  vim.cmd("tabnew")

  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(bufnr, "vim-practice://playground-" .. bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, original_text)

  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false
  vim.bo[bufnr].filetype = "text"
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].modified = false

  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true
  vim.wo.wrap = false

  local group = vim.api.nvim_create_augroup("vim_practice_" .. bufnr, { clear = true })

  -- The buffer is intentionally disposable, so quitting never asks to save it.
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.bo[bufnr].modified = false
      end
    end,
  })

  vim.keymap.set("n", "<leader>w", function()
    vim.bo[bufnr].modified = false
    vim.notify("Practice buffer is temporary; nothing was written")
  end, { buffer = bufnr, desc = "Acknowledge temporary practice buffer" })

  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

return M
