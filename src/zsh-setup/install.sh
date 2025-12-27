#!/bin/bash
set -e

USERNAME="${USERNAME:-vscode}"

# Resolve home directory for the target user.
user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [ -z "$user_home" ]; then
    echo "User $USERNAME not found."
    exit 1
fi

feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Feature install scripts run as root, so use su to apply user-scoped changes.
chsh -s "$(which zsh)" "$USERNAME"

# Install custom aliases (root-owned install, user-owned files)
install -d -m 0755 "$user_home/.devcontainer"
install -m 0644 "$feature_dir/aliases.sh" "$user_home/.devcontainer/aliases.sh"
chown -R "$USERNAME:$USERNAME" "$user_home/.devcontainer"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
su - "$USERNAME" -c "bash -lc '$script_dir/user-install.sh'"
