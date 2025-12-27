#!/bin/bash
set -e

source dev-container-features-test-lib

check "zsh is login shell" bash -c "getent passwd vscode | cut -d: -f7 | grep -q zsh"
check "theme set" bash -c "grep -q '^ZSH_THEME=\"agnoster\"' ~/.zshrc"
check "plugins set" bash -c "grep -q '^plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc"
check "aliases installed" bash -c "grep -q 'alias docker-gpu' ~/.devcontainer/aliases.sh"

reportResults
