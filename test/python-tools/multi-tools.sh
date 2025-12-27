#!/bin/bash
set -e

source dev-container-features-test-lib

check "tqdm installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | awk '{print \\$1}' | grep -qx tqdm"
check "ruff installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; uv tool list | awk '{print \\$1}' | grep -qx ruff"
check "gpustat not installed" bash -c "PATH=\"$HOME/.local/bin:$PATH\"; ! uv tool list | awk '{print \\$1}' | grep -qx gpustat"

reportResults
