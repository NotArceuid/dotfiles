#!/bin/bash

HOME_DIR="$HOME"
DOTFILES="$HOME_DIR/.dotfiles"
BACKUP_DIR="$HOME_DIR/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

PACKAGES=(
  "fastfetch"
  "rofi"
  "hyprlock"
  "hyprland"
  "kitty"
  "nvim"
  "waybar"
  "yazi"
)

SCRIPTS_DIR="$DOTFILES/Scripts"

main() {
  mkdir -p "$BACKUP_DIR"

  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES/$pkg" ]; then
      stow -v -t "$HOME_DIR" -d "$DOTFILES" "$pkg" 2>/dev/null || {
        find "$HOME_DIR" -maxdepth 1 -type l -lname "*$DOTFILES/$pkg*" -exec cp -P {} "$BACKUP_DIR/" \;
        stow -v -t "$HOME_DIR" -d "$DOTFILES" "$pkg"
      }
    fi
  done

  if [ -d "$SCRIPTS_DIR" ]; then
    cp -r "$SCRIPTS_DIR" "$HOME_DIR/"
  fi
}

main "$@"
