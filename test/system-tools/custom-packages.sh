#!/bin/bash
set -e

source dev-container-features-test-lib

check "user exists" getent passwd vscode
check "zsh installed" command -v zsh

reportResults
