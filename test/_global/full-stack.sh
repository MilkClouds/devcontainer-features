#!/bin/bash
set -e

source dev-container-features-test-lib

check "user exists" getent passwd vscode
check "tqdm installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | sed 's/ .*//' | grep -qx tqdm"

reportResults
