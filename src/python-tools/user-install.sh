#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- -b "$HOME/.local/bin"
fi

tool_list="${TOOLS:-}"
if [ -z "$tool_list" ]; then
    tool_list="tqdm gpustat glances ruff ty"
else
    tool_list="$(printf "%s\n" "$tool_list" | tr "," " ")"
fi

installed_tools="$(uv tool list 2>/dev/null | awk "{print \$1}")"
for tool in $tool_list; do
    if ! echo "$installed_tools" | grep -qx "$tool"; then
        uv tool install "$tool"
    fi
done
