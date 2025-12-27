#!/bin/bash
set -e

USERNAME="${USERNAME:-${_REMOTE_USER:-vscode}}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail() {
    echo "$1" >&2
    exit 1
}

require_cmd() {
    local cmd="$1"
    local hint="$2"
    command -v "$cmd" >/dev/null 2>&1 || fail "$hint"
}

ensure_zsh_installed() {
    if command -v zsh >/dev/null 2>&1; then
        return
    fi
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends zsh
}

# Resolve home directory for the target user.
user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
[ -n "$user_home" ] || fail "User $USERNAME not found. Ensure the user is created before running this feature."
[ -d "$user_home" ] || fail "Home directory $user_home for $USERNAME does not exist."

ensure_zsh_installed
require_cmd curl "curl is required for installing Oh My Zsh. Install curl before running this feature."
require_cmd git "git is required for installing Oh My Zsh plugins. Install git before running this feature."

# Feature install scripts run as root, so use su to apply user-scoped changes.
chsh -s "$(which zsh)" "$USERNAME"

# Install custom aliases (root-owned install, user-owned files)
install -d -m 0755 "$user_home/.devcontainer"
install -m 0644 "$script_dir/aliases.sh" "$user_home/.devcontainer/aliases.sh"
chown -R "$USERNAME:$USERNAME" "$user_home/.devcontainer"

su - "$USERNAME" -c "bash -lc '$script_dir/user-install.sh'"
