#!/bin/bash
set -e

source dev-container-features-test-lib

CONDA_INSTALL_PATH="/opt/conda"

check "conda binary exists" test -x "$CONDA_INSTALL_PATH/bin/conda"
check "conda on PATH" bash -lc "command -v conda"
check "channel priority configured" bash -lc "conda config --system --show channel_priority | grep -q 'channel_priority: strict'"
check "always yes configured" bash -lc "conda config --system --show always_yes | grep -qi 'always_yes: *true'"
check "show channel urls configured" bash -lc "conda config --system --show show_channel_urls | grep -qi 'show_channel_urls: *true'"

reportResults
