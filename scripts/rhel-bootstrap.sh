#!/bin/sh
# Set up a fresh RHEL system (for example RHEL on WSL 2) from nothing:
#   1. register it with Red Hat so dnf has package sources
#   2. install git, clone or update the dotfiles
#   3. run install.sh --install-tools (git, which, gh, Nushell, linked configuration)
#   4. optionally make Nushell the login shell
#
# Run it as your normal user (it uses sudo when needed):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/nishkodotco/dotfiles/main/scripts/rhel-bootstrap.sh)"
#
# Registration without prompts: export RHSM_ORG and RHSM_ACTIVATION_KEY first
# (create a key at https://console.redhat.com/insights/connector/activation-keys).
# Without them it asks for your Red Hat username and password.
# Set DOTFILES_NU_SHELL=0 to keep the current login shell.
set -eu

REPO=${DOTFILES_REPO:-https://github.com/nishkodotco/dotfiles}
DIR=${DOTFILES_DIR:-$HOME/dotfiles}
SUDO=
[ "$(id -u)" -eq 0 ] || SUDO=sudo

step() { printf '\n==> %s\n' "$*"; }

has_repos() {
    [ -n "$($SUDO dnf repolist --enabled -q 2>/dev/null)" ]
}

if [ ! -f /etc/redhat-release ] || ! command -v dnf >/dev/null 2>&1; then
    echo 'This script is for RHEL (dnf and /etc/redhat-release are missing).' >&2
    exit 1
fi

if has_repos; then
    step 'Package sources are already enabled; skipping registration.'
else
    step 'Registering this system with Red Hat'
    if [ -n "${RHSM_ORG:-}" ] && [ -n "${RHSM_ACTIVATION_KEY:-}" ]; then
        $SUDO subscription-manager register --org "$RHSM_ORG" --activationkey "$RHSM_ACTIVATION_KEY"
    else
        $SUDO subscription-manager register
    fi
    has_repos || { echo 'Registration finished but no package sources are enabled. Check your subscription at https://developers.redhat.com.' >&2; exit 1; }
fi

step 'Installing git'
command -v git >/dev/null 2>&1 || $SUDO dnf install -y git

if [ -d "$DIR/.git" ]; then
    step "Updating $DIR"
    git -C "$DIR" pull --ff-only
else
    step "Cloning $REPO into $DIR"
    git clone "$REPO" "$DIR"
fi

step 'Installing tools and linking configuration'
"$DIR/install.sh" --install-tools

NU="$HOME/.local/bin/nu"
command -v nu >/dev/null 2>&1 && NU=$(command -v nu)
if [ "${DOTFILES_NU_SHELL:-1}" = 1 ] && [ -x "$NU" ] && [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$NU" ]; then
    step 'Making Nushell the login shell'
    grep -qxF "$NU" /etc/shells || echo "$NU" | $SUDO tee -a /etc/shells >/dev/null
    if command -v chsh >/dev/null 2>&1; then
        $SUDO chsh -s "$NU" "$(id -un)"
    else
        $SUDO usermod -s "$NU" "$(id -un)"
    fi
fi

step 'Done. Open a new terminal to start using it.'
for tool in git which cat gh; do printf '  %-6s %s\n' "$tool" "$(command -v "$tool")"; done
printf '  %-6s %s\n' nu "$NU"
