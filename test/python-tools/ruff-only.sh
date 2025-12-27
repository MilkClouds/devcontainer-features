#!/bin/bash
set -e

source dev-container-features-test-lib

export PATH="$HOME/.local/bin:$PATH"

check "ruff installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | awk '{print \$1}' | grep -qx ruff"
check "tqdm not installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; ! uv tool list | awk '{print \$1}' | grep -qx tqdm"

reportResults
