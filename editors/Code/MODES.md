# Normal and Insert mode in VS Code (no Vim extension)

Files open read-only because the Machine Learning profile sets `"files.readonlyInclude": {"**": true}`.
A read-only file is **Normal mode**: keys move and act, typing does nothing.
An editable file is **Insert mode**: you type as usual.
The keys live in `keybindings.json` (section "Normal / Insert mode") and only fire in a file that can be made editable.

## Normal mode

| Key | Does |
|---|---|
| `i` | Insert mode at the cursor |
| `a` / `A` | Insert after the cursor / at the end of the line |
| `I` | Insert at the start of the line |
| `o` / `O` | New line below / above, then Insert mode |
| `h` `j` `k` `l` | Left, down, up, right |
| `w` / `b` / `e` | Next word / previous word / end of word |
| `0` / `$` | Start / end of the line |
| `gg` / `G` | Top / bottom of the file |
| `Ctrl+D` / `Ctrl+U` | Page down / page up |
| `v` / `V` | Start a selection / select the line |
| `y` | Copy the selection (the whole line when nothing is selected) |
| `p` | Paste |
| `x` | Delete the character under the cursor |
| `dd` | Delete the line |
| `u` / `Ctrl+R` | Undo / redo |
| `/` then `n` / `N` | Search, next match, previous match |

## Insert mode

Type normally. `Esc` returns to Normal mode, unless a suggestion list, find box, rename box,
snippet or multi-cursor is active (then `Esc` closes that first, and a second `Esc` returns to Normal).

## Cmd shortcuts that Normal mode replaces

These still work today. Each one can be removed to free the key, because Normal mode covers it:

| Shortcut | Normal-mode replacement |
|---|---|
| Cmd+C | `y` |
| Cmd+V | `p` |
| Cmd+X | `dd` (line) or `v` + `x` |
| Cmd+Z / Cmd+Shift+Z | `u` / `Ctrl+R` |
| Cmd+F, Cmd+G, Cmd+Shift+G | `/`, `n`, `N` |
| Cmd+Up / Cmd+Down | `gg` / `G` |
| Cmd+Left / Cmd+Right in a file | `0` / `$` |
| Cmd+L (select line) | `V` |
| Cmd+Shift+K (delete line) | `dd` |
| Cmd+Enter / Cmd+Shift+Enter (new line below/above) | `o` / `O` |

Removing them affects only the editor; the terminal, side bar and text boxes keep their own behavior.

## Terminal (Nushell)

Nushell has the same idea built in: `$env.config.edit_mode = "vi"` in `config.nu`.
The prompt starts in Insert mode; `Esc` switches to Normal mode, where `h l w b e 0 $ x dd p u i a A I`
behave like the table above, and `Enter` runs the command from either mode.
