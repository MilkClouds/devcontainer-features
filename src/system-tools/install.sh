#!/bin/bash
set -e

USERNAME="${USERNAME:-${_REMOTE_USER:-vscode}}"
USER_UID="${USER_UID:-${USERUID:-1000}}"
USER_GID="${USER_GID:-${USERGID:-1000}}"

fail() {
    echo "$1" >&2
    exit 1
}

normalize_list() {
    printf "%s\n" "$1" | tr "," " "
}

has_token() {
    local haystack="$1"
    local needle="$2"
    for token in $haystack; do
        [ "$token" = "$needle" ] && return 0
    done
    return 1
}

echo "Setting up devcontainer for user: $USERNAME (UID: $USER_UID, GID: $USER_GID)"

# Set locale and environment
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Create or update group
group_by_name_gid="$(getent group "$USERNAME" | cut -d: -f3)"
group_by_gid_name="$(getent group "$USER_GID" | cut -d: -f1)"
if [ -n "$group_by_name_gid" ]; then
    if [ "$group_by_name_gid" != "$USER_GID" ]; then
        if [ -n "$group_by_gid_name" ] && [ "$group_by_gid_name" != "$USERNAME" ]; then
            fail "Group name $USERNAME exists with GID $group_by_name_gid, but GID $USER_GID is owned by $group_by_gid_name"
        fi
        echo "Updating group $USERNAME GID: $group_by_name_gid -> $USER_GID"
        groupmod -g "$USER_GID" "$USERNAME"
    else
        echo "Group $USERNAME (GID: $USER_GID) already exists"
    fi
elif [ -n "$group_by_gid_name" ]; then
    echo "Renaming existing group: $group_by_gid_name (GID: $USER_GID) -> $USERNAME"
    groupmod -n "$USERNAME" "$group_by_gid_name"
else
    groupadd -g "$USER_GID" "$USERNAME"
fi

# Create or update user
user_by_name_uid="$(getent passwd "$USERNAME" | cut -d: -f3)"
user_by_uid_name="$(getent passwd "$USER_UID" | cut -d: -f1)"
if [ -n "$user_by_name_uid" ]; then
    if [ "$user_by_name_uid" != "$USER_UID" ]; then
        if [ -n "$user_by_uid_name" ] && [ "$user_by_uid_name" != "$USERNAME" ]; then
            fail "User name $USERNAME exists with UID $user_by_name_uid, but UID $USER_UID is owned by $user_by_uid_name"
        fi
        echo "Updating user $USERNAME UID: $user_by_name_uid -> $USER_UID"
        usermod -u "$USER_UID" "$USERNAME"
    else
        echo "User $USERNAME (UID: $USER_UID) already exists"
    fi
    usermod -g "$USER_GID" "$USERNAME"
    current_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
    if [ "$current_home" != "/home/$USERNAME" ]; then
        usermod -d "/home/$USERNAME" -m "$USERNAME"
    fi
elif [ -n "$user_by_uid_name" ]; then
    echo "Renaming existing user: $user_by_uid_name (UID: $USER_UID) -> $USERNAME"
    usermod -l "$USERNAME" "$user_by_uid_name"
    usermod -d "/home/$USERNAME" -m "$USERNAME"
    usermod -g "$USER_GID" "$USERNAME"
else
    useradd -m -s /bin/bash -u "$USER_UID" -g "$USER_GID" "$USERNAME"
fi

# Remove passwords for passwordless sudo
passwd -d root || true
passwd -d "$USERNAME" || true

# Update package lists
apt-get update

exclude_packages="$(normalize_list "${EXCLUDE_PACKAGES:-}")"
install_packages() {
    local selected=()
    local pkg
    for pkg in "$@"; do
        if ! has_token "$exclude_packages" "$pkg"; then
            selected+=("$pkg")
        fi
    done
    if [ "${#selected[@]}" -gt 0 ]; then
        apt-get install -y --no-install-recommends "${selected[@]}"
    fi
}

# Install system utilities and shell tools
install_packages sudo bash-completion zsh tmux htop tree locales

# Install editors and text processing
install_packages vim vim-runtime nano

# Install network and download tools
install_packages git curl wget aria2 openssh-client jq unzip rsync xz-utils

# Install development tools and libraries
install_packages build-essential libssl-dev zlib1g-dev libffi-dev libreadline-dev libsqlite3-dev libncursesw5-dev

# Install X11 applications and utilities
install_packages x11-apps xauth

# Install optional extra packages
extra_packages="$(normalize_list "${PACKAGES:-}")"
if [ -n "$extra_packages" ]; then
    install_packages $extra_packages
fi

# Generate locale and configure sudoers
if command -v locale-gen >/dev/null 2>&1; then
    locale-gen en_US.UTF-8
fi
if getent group sudo >/dev/null 2>&1; then
    usermod -aG sudo "$USERNAME"
fi
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

echo "System tools setup completed successfully"
