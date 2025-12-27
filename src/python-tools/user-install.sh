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
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- -b "$HOME/.local/bin"
fi

tool_list="${TOOLS:-}"
if [ -z "$tool_list" ]; then
    tool_list="tqdm gpustat glances ruff ty"
else
    tool_list="$(normalize_list "$tool_list")"
fi

installed_tools="$(uv tool list 2>/dev/null | awk "{print \$1}")"
for tool in $tool_list; do
    if ! has_token "$installed_tools" "$tool"; then
        uv tool install "$tool"
    fi
done
