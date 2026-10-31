#!/usr/bin/env bash
# Copies these VS Code shortcuts into VS Code on macOS and Linux.
# Run it after cloning or pulling the dotfiles repo (MLverse also runs a copy on workspace open).
# Targets the default keybindings.json and every profile that has its own keybindings.json.
# The first time a different file is replaced, the old one is kept as keybindings.backup.json.
# Targets that are symlinks are left alone: they are managed elsewhere (e.g. the xponent repo).

set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
  Darwin) source="$here/keybindings.mac.json"; user="$HOME/Library/Application Support/Code/User" ;;
  Linux)  source="$here/keybindings.windows.json"; user="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
  *) echo "Unsupported OS: $(uname -s)"; exit 0 ;;
esac

[ -f "$source" ] || { echo "Missing $source"; exit 1; }
[ -d "$user" ] || { echo "VS Code user folder not found: $user"; exit 0; }

targets=("$user/keybindings.json")
for f in "$user"/profiles/*/keybindings.json; do
  [ -e "$f" ] || [ -L "$f" ] || continue
  targets+=("$f")
done

for target in "${targets[@]}"; do
  if [ -L "$target" ]; then echo "Skipped (symlink, managed elsewhere): $target"; continue; fi
  if [ -f "$target" ] && cmp -s "$source" "$target"; then continue; fi
  backup="$(dirname "$target")/keybindings.backup.json"
  if [ -f "$target" ] && [ ! -e "$backup" ]; then cp "$target" "$backup"; fi
  cp "$source" "$target"
  echo "Updated $target"
done
