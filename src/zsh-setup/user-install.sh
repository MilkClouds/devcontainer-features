#!/bin/bash
set -e

export RUNZSH=no CHSH=no

normalize_list() {
  printf "%s\n" "$1" | tr "," " "
}

has_token() {
  local haystack="$1"
  local needle="$2"
  for token in $haystack; do
    [ "$token" = "$needle" ] && return 0
  done
  return 1
}

plugin_list="${PLUGINS:-}"
if [ -z "$plugin_list" ]; then
  plugin_list="git zsh-autosuggestions zsh-syntax-highlighting"
else
  plugin_list="$(normalize_list "$plugin_list")"
fi
theme_name="${THEME:-agnoster}"

if [ ! -d ~/.oh-my-zsh ]; then
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Ensure custom plugins directory exists
mkdir -p ~/.oh-my-zsh/custom/plugins
if has_token "$plugin_list" "zsh-autosuggestions"; then
  if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  fi
fi
if has_token "$plugin_list" "zsh-syntax-highlighting"; then
  if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
fi

# Configure .zshrc
if [ ! -f ~/.zshrc ]; then
  touch ~/.zshrc
fi
if grep -q "^plugins=" ~/.zshrc; then
  sed -i "s/^plugins=.*/plugins=($plugin_list)/" ~/.zshrc
else
  printf "\nplugins=(%s)\n" "$plugin_list" >> ~/.zshrc
fi
if grep -q "^ZSH_THEME=" ~/.zshrc; then
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$theme_name\"/" ~/.zshrc
else
  printf "\nZSH_THEME=\"%s\"\n" "$theme_name" >> ~/.zshrc
fi
if ! grep -q "export LC_ALL=C.UTF-8" ~/.zshrc; then
  printf "\n# Locale settings\nexport LC_ALL=C.UTF-8\nexport LANG=C.UTF-8\n" >> ~/.zshrc
fi

# Source custom aliases
if ! grep -q "source ~/.devcontainer/aliases.sh" ~/.zshrc; then
  printf "\n# Custom aliases and functions\nsource ~/.devcontainer/aliases.sh\n" >> ~/.zshrc
fi
