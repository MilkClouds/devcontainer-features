#!/bin/bash
set -e

source dev-container-features-test-lib

check "ripgrep installed" command -v rg
check "x11-apps excluded" bash -c "! dpkg -s x11-apps >/dev/null 2>&1"

reportResults
