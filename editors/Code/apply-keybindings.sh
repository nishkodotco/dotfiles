#!/usr/bin/env bash
# Applies these VS Code shortcuts on macOS and Linux, for the default profile and every other profile.
# macOS uses keybindings.json (Cmd keys), Linux uses keybindings.windows.json (Ctrl keys).
# Targets that already link to the right file are left alone; other links are skipped.
# The first time a different file is replaced, the old one is kept as keybindings.backup.json.
# On a Mac where ./install.sh has run, every target is already a link, so this does nothing.

set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
  Darwin) source="$here/keybindings.json"; user="$HOME/Library/Application Support/Code/User" ;;
  Linux)  source="$here/keybindings.windows.json"; user="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
  *) echo "Unsupported OS: $(uname -s)"; exit 0 ;;
esac

[ -f "$source" ] || { echo "Missing $source"; exit 1; }
[ -d "$user" ] || { echo "VS Code user folder not found: $user"; exit 0; }

targets=("$user/keybindings.json")
for dir in "$user"/profiles/*/; do
  [ -d "$dir" ] && targets+=("${dir%/}/keybindings.json")
done

for target in "${targets[@]}"; do
  if [ -L "$target" ]; then
    [ "$(realpath "$target" 2>/dev/null)" = "$(realpath "$source")" ] && continue
    echo "Skipped (link to another file, managed elsewhere): $target"; continue
  fi
  if [ -f "$target" ] && cmp -s "$source" "$target"; then continue; fi
  backup="$(dirname "$target")/keybindings.backup.json"
  if [ -f "$target" ] && [ ! -e "$backup" ]; then cp "$target" "$backup"; fi
  cp "$source" "$target"
  echo "Updated $target"
done
