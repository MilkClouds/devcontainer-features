#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

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

if ! command -v uv >/dev/null 2>&1; then
    XDG_BIN_HOME="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 \
        curl -LsSf https://astral.sh/uv/install.sh | sh
fi

tool_list="$(normalize_list "${TOOLS:-}")"
if [ -z "$tool_list" ]; then
    echo "No tools configured. Set the tools option to install uv tools." >&2
    exit 0
fi

installed_tools="$(uv tool list 2>/dev/null | awk "{print \$1}")"
for tool in $tool_list; do
    if ! has_token "$installed_tools" "$tool"; then
        uv tool install "$tool"
    fi
done
