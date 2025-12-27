#!/bin/bash
set -e

source dev-container-features-test-lib

export PATH="$HOME/.local/bin:$PATH"

check "uv installed" command -v uv
check "tqdm installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | awk '{print \$1}' | grep -qx tqdm"
check "ruff installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | awk '{print \$1}' | grep -qx ruff"

reportResults
