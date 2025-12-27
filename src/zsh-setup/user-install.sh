#!/bin/bash
set -e

export RUNZSH=no CHSH=no

if [ ! -d ~/.oh-my-zsh ]; then
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Ensure custom plugins directory exists
mkdir -p ~/.oh-my-zsh/custom/plugins
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# Configure .zshrc
if [ ! -f ~/.zshrc ]; then
  touch ~/.zshrc
fi
if grep -q "^plugins=" ~/.zshrc; then
  sed -i "s/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/" ~/.zshrc
else
  printf "\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\n" >> ~/.zshrc
fi
if grep -q "^ZSH_THEME=" ~/.zshrc; then
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnoster\"/" ~/.zshrc
else
  printf "\nZSH_THEME=\"agnoster\"\n" >> ~/.zshrc
fi
if ! grep -q "export LC_ALL=C.UTF-8" ~/.zshrc; then
  printf "\n# Locale settings\nexport LC_ALL=C.UTF-8\nexport LANG=C.UTF-8\n" >> ~/.zshrc
fi

# Source custom aliases
if ! grep -q "source ~/.devcontainer/aliases.sh" ~/.zshrc; then
  printf "\n# Custom aliases and functions\nsource ~/.devcontainer/aliases.sh\n" >> ~/.zshrc
fi
