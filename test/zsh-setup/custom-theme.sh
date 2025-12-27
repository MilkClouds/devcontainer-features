#!/bin/bash
set -e

source dev-container-features-test-lib

check "theme set" bash -c "grep -q '^ZSH_THEME=\"robbyrussell\"' ~/.zshrc"
check "plugins set" bash -c "grep -q '^plugins=(git)' ~/.zshrc"
check "no autosuggestions plugin" bash -c "[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]"
check "no syntax highlighting plugin" bash -c "[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]"

reportResults
