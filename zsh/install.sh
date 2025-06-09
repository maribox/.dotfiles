#!/usr/bin/env bash
set -euo pipefail

# 1. Detect if zsh is installed
if ! command -v zsh &>/dev/null; then
  echo "→ zsh not found. Installing…"
  if   command -v dnf        &>/dev/null; then sudo dnf install -y zsh
  elif command -v apt-get    &>/dev/null; then sudo apt-get update && sudo apt-get install -y zsh
  else
    echo "✗ No supported package manager (dnf/apt-get). Install zsh manually." >&2
    exit 1
  fi
else
  echo "✔ zsh is already installed."
fi

# 2. Get the absolute path of zsh
ZSH_PATH=$(command -v zsh)

# 3. Check your current login shell in /etc/passwd
CURRENT_LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)

if [ "$CURRENT_LOGIN_SHELL" != "$ZSH_PATH" ]; then
  echo "→ Current login shell is $CURRENT_LOGIN_SHELL. Switching to $ZSH_PATH…"
  # Change default shell for your user
  sudo chsh -s "$ZSH_PATH" "$USER"
  echo "✔ Default shell changed to zsh. Log out and back in to apply."
else
  echo "✔ zsh is already your default shell."
fi

if [ -f ~/.zshrc ] && ! grep -Fxq -f ~/.dotfiles/zsh/.zshrc ~/.zshrc; then
	if cat ~/.dotfiles/zsh/.zshrc >> ~/.zshrc; then
		echo "✔ Added link to shared_rc to ~/.zshrc"
	fi
fi

CURRENT_SHELL="$(ps -p $$ -o comm=)"

if [ "$CURRENT_SHELL" != "zsh" ]; then
       	if [ -e /bin/zsh ]; then 
		echo "Switching to zsh..."
		/bin/zsh
	fi
fi
