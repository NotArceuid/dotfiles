#!/bin/sh

USER_HOME="$1"
DOTFILES_DIR="$USER_HOME/.dotfiles"
BACKUP_DIR="$USER_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

post_install() {
  echo "Running post-installation configuration..."

  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  echo "Post-installation configuration completed"
}

post_install
