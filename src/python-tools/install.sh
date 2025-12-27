#!/bin/bash
set -e

USERNAME="${USERNAME:-${_REMOTE_USER:-vscode}}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail() {
    echo "$1" >&2
    exit 1
}

user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
[ -n "$user_home" ] || fail "User $USERNAME not found."

if ! command -v curl >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
fi

tools_env="${TOOLS:-}"
su - "$USERNAME" -c "TOOLS=$(printf '%q' "$tools_env") bash -lc '$script_dir/user-install.sh'"
