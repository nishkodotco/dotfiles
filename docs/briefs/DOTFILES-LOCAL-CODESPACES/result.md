# Done

Made dotfiles the source for shared non-secret development settings.
Applied managed symlinks on the Mac.
Preserved previous settings in local backups.
Configured Nushell PATH and structured docker ps output.
Preserved shell, Ghostty, Neovim, Fish, tmux, Git, and editor preferences.
Created the Xponent VS Code profile and associated the workspace.
Installed Flutter, C#, container, and YAML extensions in that profile.
Set terminals to open in editor tabs.
Set Ctrl+` to create an editor terminal.
Moved Xponent tasks to workspace level.
Moved Xponent-specific profile and workspace sources into app.xponent.automation at nishko's request.
Linked the registered VS Code profile to those project files.
Added a checksum-verified Linux Nushell installer for development containers and Codespaces.

# Changed files

.config/, editors/, scripts/, install.sh, Brewfile, xponent.code-workspace, .devcontainer/devcontainer.json, shell startup files, README.md, tests/, and AGENTS.md.

# Commands and results

python3 -m unittest discover -s tests -v: 2 tests passed.
./install.sh: applied configuration and preserved original files.
./install.sh --check: passed.
Nushell docker ps: returned a structured table.
Nushell docker ps -q: preserved plain container IDs.
Clean python:3.12-slim container: installed verified Nushell 0.113.1, applied shared configuration, and resolved nu and dotfiles commands.
VS Code --profile Xponent: created the profile and opened the workspace.
VS Code extension installation: succeeded.

# Screenshots

No screenshot was required for configuration installation.

# Blocked

The current GitHub CLI login lacks the codespace scope.
Could not configure the user's Codespaces account settings or existing Codespaces.

# Needs from nishko

In https://github.com/settings/codespaces, enable Automatically install dotfiles and select nishkodotco/dotfiles.
Restart existing shells to load shared configuration.
