#!/bin/bash
set -e

USERNAME="${USERNAME:-vscode}"

# Resolve home directory for the target user.
user_home="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [ -z "$user_home" ]; then
    echo "User $USERNAME not found."
    exit 1
fi

feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Feature install scripts run as root, so use su to apply user-scoped changes.
chsh -s "$(which zsh)" "$USERNAME"

# Install custom aliases (root-owned install, user-owned files)
install -d -m 0755 "$user_home/.devcontainer"
install -m 0644 "$feature_dir/aliases.sh" "$user_home/.devcontainer/aliases.sh"
chown -R "$USERNAME:$USERNAME" "$user_home/.devcontainer"

# Run user-scoped setup in a single block for readability.
su - "$USERNAME" -c "bash -lc '
export RUNZSH=no CHSH=no

if [ ! -d ~/.oh-my-zsh ]; then
  # Install Oh My Zsh
  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"
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
if grep -q \"^plugins=\" ~/.zshrc; then
  sed -i \"s/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/\" ~/.zshrc
else
  printf \"\\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\\n\" >> ~/.zshrc
fi
if grep -q \"^ZSH_THEME=\" ~/.zshrc; then
  sed -i \"s/^ZSH_THEME=.*/ZSH_THEME=\\\"agnoster\\\"/\" ~/.zshrc
else
  printf \"\\nZSH_THEME=\\\"agnoster\\\"\\n\" >> ~/.zshrc
fi
if ! grep -q \"export LC_ALL=C.UTF-8\" ~/.zshrc; then
  printf \"\\n# Locale settings\\nexport LC_ALL=C.UTF-8\\nexport LANG=C.UTF-8\\n\" >> ~/.zshrc
fi

# Source custom aliases
if ! grep -q \"source ~/.devcontainer/aliases.sh\" ~/.zshrc; then
  printf \"\\n# Custom aliases and functions\\nsource ~/.devcontainer/aliases.sh\\n\" >> ~/.zshrc
fi
'"
