# VS Code keyboard shortcuts

This folder is the single source for my VS Code shortcuts.
Shortcuts are per user, not per project, so every folder and workspace gets them.

| File | For |
|---|---|
| `keybindings.json` | macOS (master copy, edit this one) |
| `keybindings.windows.json` | Windows and Linux, generated from the Mac file |
| `apply-keybindings.sh` | applies them on macOS and Linux |
| `apply-keybindings.ps1` | applies them on Windows |

After editing `keybindings.json`, regenerate the Windows file:

```bash
python3 scripts/make-windows-keybindings.py
```

## Apply on a machine

macOS: `./install.sh` links `keybindings.json` into the default profile and every profile under
`~/Library/Application Support/Code/User/profiles/`. Edits then apply immediately.
Run it again after creating a new VS Code profile.

Linux:

```bash
editors/Code/apply-keybindings.sh
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File editors\Code\apply-keybindings.ps1
```

The apply scripts copy into the default profile and every profile, skip files that are already
identical or already linked, and keep a one-time `keybindings.backup.json`.
Opening the MLverse workspace runs them automatically.

## Mac to Windows/Linux keys

Mac Cmd becomes Ctrl, Mac Ctrl becomes Alt, Mac Cmd+Ctrl becomes Ctrl+Alt, and Alt stays Alt.
These got their own Windows key to avoid a clash: Run task (Ctrl+Shift+Alt+T),
Start debugging (F5), Reveal file in Explorer (Ctrl+Shift+Alt+R),
Collapse Explorer folders (Ctrl+Shift+Alt+X), Git open changes (Ctrl+Shift+Alt+V)
and Git push (Ctrl+Shift+Alt+Y).
