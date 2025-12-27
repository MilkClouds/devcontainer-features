#!/bin/bash
set -e

USERNAME="${USERNAME:-${_REMOTE_USER:-vscode}}"

# Resolve home directory for the target user.
user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [ -z "$user_home" ]; then
    echo "User $USERNAME not found. Ensure the user is created before running this feature." >&2
    exit 1
fi
if [ ! -d "$user_home" ]; then
    echo "Home directory $user_home for $USERNAME does not exist." >&2
    exit 1
fi
missing_packages=()
if ! command -v zsh >/dev/null 2>&1; then
    missing_packages+=("zsh")
fi
if [ "${#missing_packages[@]}" -gt 0 ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${missing_packages[@]}"
fi
if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for installing Oh My Zsh. Install curl before running this feature." >&2
    exit 1
fi
if ! command -v git >/dev/null 2>&1; then
    echo "git is required for installing Oh My Zsh plugins. Install git before running this feature." >&2
    exit 1
fi

# Feature install scripts run as root, so use su to apply user-scoped changes.
chsh -s "$(which zsh)" "$USERNAME"

# Install custom aliases (root-owned install, user-owned files)
feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install -d -m 0755 "$user_home/.devcontainer"
install -m 0644 "$feature_dir/aliases.sh" "$user_home/.devcontainer/aliases.sh"
chown -R "$USERNAME:$USERNAME" "$user_home/.devcontainer"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
su - "$USERNAME" -c "bash -lc '$script_dir/user-install.sh'"
