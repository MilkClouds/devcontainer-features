#!/bin/bash
set -e

source dev-container-features-test-lib

export PATH="$HOME/.local/bin:$PATH"

check "zsh is login shell" bash -c "getent passwd vscode | cut -d: -f7 | grep -q zsh"
check "tqdm installed" bash -lc "uv tool list | awk '{print \$1}' | grep -qx tqdm"
check "aliases installed" bash -c "grep -q 'alias docker-gpu' ~/.devcontainer/aliases.sh"

reportResults
