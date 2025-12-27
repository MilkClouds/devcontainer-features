#!/bin/bash
set -e

source dev-container-features-test-lib

check "tqdm installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | sed 's/ .*//' | grep -qx tqdm"
check "ruff installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | sed 's/ .*//' | grep -qx ruff"
check "gpustat not installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; ! uv tool list | sed 's/ .*//' | grep -qx gpustat"

reportResults
