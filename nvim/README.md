# Neovim configuration

A small keyboard-first configuration for C, C++, Rust, Assembly, and OS work.

The native `caelestia` colorscheme reads the current palette from
`~/.local/state/caelestia/theme/nvim`. It follows Caelestia scheme changes while
Neovim is running and falls back to a quiet built-in palette when that file is
unavailable. Run `:CaelestiaReload` to force a manual refresh.

The statusline is also native Lua. It shows the current mode, file state,
diagnostic counts, attached language servers, filetype, and cursor position,
using the same live Caelestia palette.

Starting plain `nvim` opens a native, plugin-free dashboard built around the
official filled Vim ASCII logo. The logo uses the classic Vim colours while the
rest follows Caelestia; opening a file directly skips the dashboard.

## Start here

Run `:Tutor` inside Neovim. It teaches the editing language that this config is
built around. Press `Space` and wait to see configured leader mappings.

Press `Space h` or run `:VimGuide` to open the searchable Russian-language
cheat sheet. Use `/` inside it to search for a command or topic.

Press `Space p` or run `:VimPractice` to open a disposable practice buffer in
a new tab. Close it with `:q`; every new session starts from the original text.

Arrow keys are disabled while editing. Use `h`, `j`, `k`, and `l` for basic
movement, then gradually replace repeated presses with the motions below.

Think of Normal-mode commands as short sentences:

- `w`, `b`, `e`: move by words
- `0`, `^`, `$`: move within a line
- `f<char>`, `t<char>`: move to a character on the current line
- `d`, `c`, `y`: delete, change, or yank using a following motion
- `ciw`: change the word under the cursor
- `di"`: delete inside quotes
- `u`, `<C-r>`: undo and redo
- `/text`, `n`, `N`: search and move through matches
- `p`, `P`: put yanked or deleted text
- `.`: repeat the last change

## Configured keys

| Key | Action |
| --- | --- |
| `Space ?` | Show keymap help |
| `Space h` | Open the searchable Vim guide |
| `Space p` | Open a disposable practice buffer |
| `Space f f` | Find files |
| `Space f g` | Find text in the project |
| `Space f b` | Find open buffers |
| `Space f r` | Find recent files |
| `Space e` | Toggle the file tree |
| `Space E` | Reveal the current file in the tree |
| `[b` / `]b` | Previous / next buffer |
| `Space b a` / `Ctrl-^` | Switch to the alternate buffer |
| `Space b d` | Close the current buffer, confirming modified files |
| `Space b o` | Close other buffers, preserving modified files |
| `Ctrl-h/j/k/l` | Move between windows |
| `Space d d` | Explain the diagnostic under the cursor |
| `[d` / `]d` | Previous / next diagnostic |
| `gd` | Go to definition (when LSP is attached) |
| `grr` | Find references (when LSP is attached) |
| `K` | Show symbol documentation (when LSP is attached) |
| `Space c r` | Rename a symbol |
| `Space c a` | Show code actions |
| `Space c f` | Format the current buffer |

## Formatting

C and C++ use `clang-format`; Rust uses `rustfmt`. Formatting runs before every
save and respects project configuration files.

- `:FormatDisable` disables automatic formatting globally.
- `:FormatDisable!` disables it for the current buffer.
- `:FormatEnable` enables it again.

## External tools

The configuration uses tools from the system instead of downloading language
servers behind your back.

- C and C++ analysis: `clangd`
- C and C++ formatting: `clang-format`
- Rust analysis: `rust-analyzer`
- Rust formatting: `rustfmt`
- Project search: `fzf` and `rg`

`rust-analyzer` is not currently installed on this machine. On Gentoo it is
provided by the `rust-analyzer` USE flag of the Rust package. Until that flag is
enabled, Rust editing and formatting work, but LSP diagnostics and navigation do
not start.

## Maintenance

- `:Lazy` opens the plugin manager.
- `:Lazy update` updates plugins explicitly and refreshes `lazy-lock.json`.
- `:checkhealth` checks Neovim and plugin dependencies.
- `:ConformInfo` explains which formatter is active for the current buffer.
