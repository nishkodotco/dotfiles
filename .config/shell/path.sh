# Shared POSIX shell PATH. No credentials belong here.
for dotfiles_path in "$HOME/.local/bin" /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin "$HOME/Library/Android/sdk/platform-tools" "$HOME/Android/Sdk/platform-tools" "$HOME/.antigravity-ide/antigravity-ide/bin"; do
    if [ -d "$dotfiles_path" ]; then
        case ":$PATH:" in *":$dotfiles_path:"*) ;; *) export PATH="$dotfiles_path:$PATH" ;; esac
    fi
done
unset dotfiles_path
if [ -x '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge' ]; then
    export CHROME_EXECUTABLE='/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge'
fi
