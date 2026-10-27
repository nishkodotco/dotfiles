# Personal dotfiles

This repository is the source of truth for shared, non-secret user configuration.
It supports macOS, Linux development containers, and GitHub Codespaces.

## Apply configuration

Run `./install.sh` from the checkout.
The installer backs up existing files under `~/.local/state/dotfiles/backups/`.
It links the active configuration paths to this checkout.
Edit the tracked files to change the active configuration.
Restart the affected shell or application after a change.

Managed settings include Nushell, Bash, Zsh, Fish, Ghostty, Neovim, tmux, and Git.
`Brewfile` records the Mac development tools.
Run `brew bundle --file Brewfile` only when you want to install the full tool inventory.

## Daily changes

- `dotfiles path`: show this checkout.
- `dotfiles status`: show configuration changes.
- `dotfiles check`: detect missing or replaced links.
- `dotfiles apply`: restore the managed links.
- `dotfiles pull`: pull committed updates and apply them.

Commit and push reviewed changes from this checkout.
No background process automatically commits or publishes files.
This prevents accidental publication of credentials.
Project configuration, VS Code tasks, and container services remain in their project repositories.
Docker authentication, cloud credentials, keys, histories, virtual machines, volumes, and application databases remain outside Git.
Mac-only GUI application settings do not apply to Linux containers.

## GitHub Codespaces

Open https://github.com/settings/codespaces.
Enable **Automatically install dotfiles**.
Select **nishkodotco/dotfiles**.
New Codespaces run `install.sh` automatically.
The installer installs Nushell 0.113.1 on Linux with a pinned official SHA-256 checksum.
It changes the Codespaces user shell when passwordless sudo is available.
Existing Codespaces need the repository pulled and `./install.sh --install-tools --codespaces-shell` run once.

GitHub account settings are separate from files in this repository.
Codespaces access was not available to the current GitHub CLI login during setup.
VS Code Settings Sync controls personal editor settings that Codespaces does not load from dotfiles.

## VS Code development containers

Set these user settings in VS Code:

```json
{
  "dotfiles.repository": "https://github.com/nishkodotco/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "./install.sh --install-tools"
}
```

This repository includes a sample `.devcontainer/devcontainer.json`.
Application containers do not need personal shell dotfiles.
Use dotfiles inside interactive development containers and Codespaces.

## Validation

Run `python3 -m unittest discover -s tests -v`.
Run `./install.sh --check` on the installed machine.
Test Linux installation with the repository mounted read-only in a disposable container.

## Xponent-specific configuration

Xponent-specific profile settings and workspace tasks live inside app.xponent.automation.
Shared personal shell settings stay in this repository.
The installer can link a registered local Xponent profile to its project source.
Use --xponent-profile PATH_TO_PROFILE_DIRECTORY once to register that machine's profile directory.
Use app.xponent.automation/scripts/install-workspace.py to apply the project workspace.
Open the workspace with the Xponent VS Code profile.
