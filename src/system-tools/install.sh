#!/bin/bash
set -e

USERNAME="${USERNAME:-vscode}"
USER_UID="${USER_UID:-${USERUID:-1000}}"
USER_GID="${USER_GID:-${USERGID:-1000}}"

echo "Setting up devcontainer for user: $USERNAME (UID: $USER_UID, GID: $USER_GID)"

# Set locale and environment
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Create or rename group
existing_group="$(getent group "$USER_GID" | cut -d: -f1)"
if [ -n "$existing_group" ]; then
    if [ "$existing_group" != "$USERNAME" ]; then
        echo "Renaming existing group: $existing_group (GID: $USER_GID) -> $USERNAME"
        groupmod -n "$USERNAME" "$existing_group"
    else
        echo "Group $USERNAME (GID: $USER_GID) already exists"
    fi
else
    groupadd -g "$USER_GID" "$USERNAME"
fi

# Create or rename user
existing_user="$(getent passwd "$USER_UID" | cut -d: -f1)"
if [ -n "$existing_user" ]; then
    if [ "$existing_user" != "$USERNAME" ]; then
        echo "Renaming existing user: $existing_user (UID: $USER_UID) -> $USERNAME"
        usermod -l "$USERNAME" "$existing_user"
        usermod -d "/home/$USERNAME" -m "$USERNAME"
        usermod -g "$USER_GID" "$USERNAME"
    else
        echo "User $USERNAME (UID: $USER_UID) already exists"
    fi
else
    useradd -m -s /bin/bash -u "$USER_UID" -g "$USER_GID" "$USERNAME"
fi

# Remove passwords for passwordless sudo
passwd -d root || true
passwd -d "$USERNAME" || true

# Update package lists
apt-get update

# Install system utilities and shell tools
apt-get install -y --no-install-recommends \
    sudo bash-completion zsh tmux \
    htop tree locales

# Install editors and text processing
apt-get install -y --no-install-recommends \
    vim vim-runtime nano

# Install network and download tools
apt-get install -y --no-install-recommends \
    git curl wget aria2 openssh-client \
    jq unzip rsync xz-utils

# Install development tools and libraries
apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev zlib1g-dev libffi-dev \
    libreadline-dev libsqlite3-dev libncursesw5-dev

# Install X11 applications and utilities
apt-get install -y --no-install-recommends \
    x11-apps xauth

# Generate locale and configure sudoers
locale-gen en_US.UTF-8
usermod -aG sudo "$USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

echo "System tools setup completed successfully"
