#!/bin/bash
set -e

USERNAME="${USERNAME:-${_REMOTE_USER:-vscode}}"

user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [ -z "$user_home" ]; then
    echo "User $USERNAME not found." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
su - "$USERNAME" -c "bash -lc '$script_dir/user-install.sh'"
