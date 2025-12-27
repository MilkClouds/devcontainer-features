#!/bin/bash
set -e

source dev-container-features-test-lib

check "user exists" getent passwd vscode
check "sudoers exists" test -f /etc/sudoers.d/vscode
check "zsh installed" command -v zsh

reportResults
