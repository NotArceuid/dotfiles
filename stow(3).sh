#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
HOME_DIR="$HOME"
DOTFILES="$HOME_DIR/.dotfiles"
BACKUP_DIR="$HOME_DIR/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

log() { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# All stow packages
PACKAGES=("fastfetch" "fuzzel" "kitty" "nvim" "nwg-look" "Thunar" "waybar" "waypaper" "wayscriber" "xdg-desktop-portal" "yazi")

# Special directories that need manual setup
SCRIPTS_DIR="$DOTFILES/Scripts"

# Backup function
backup_existing() {
  info "Backing up existing files..."
  mkdir -p "$BACKUP_DIR"

  # Backup stow packages
  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES/$pkg" ]; then
      find "$DOTFILES/$pkg" -type f | while read -r file; do
        rel_path="${file#$DOTFILES/$pkg/}"
        target="$HOME_DIR/$rel_path"
        if [ -e "$target" ]; then
          mkdir -p "$(dirname "$BACKUP_DIR/$rel_path")"
          cp -r "$target" "$BACKUP_DIR/$rel_path"
        fi
      done
    fi
  done
}

# Verify structure
check_structure() {
  info "Checking structure..."

  # Check packages
  for pkg in "${PACKAGES[@]}"; do
    [ ! -d "$DOTFILES/$pkg" ] && warn "Missing: $pkg"
  done
}

# Setup scripts
setup_scripts() {
  info "Setting up scripts..."
  mkdir -p "$HOME_DIR/.local/bin"

  find "$SCRIPTS_DIR" -type f -executable -o -name "*.sh" -o -name "*.py" | while read -r script; do
    chmod +x "$script"
    base_name=$(basename "$script" | cut -d. -f1)
    ln -sf "$script" "$HOME_DIR/.local/bin/$base_name"
    info "Linked: $base_name"
  done
}

# Apply stow packages
apply_stow() {
  info "Applying packages with stow..."

  # Check for stow
  command -v stow >/dev/null 2>&1 || {
    info "Installing stow..."
    sudo pacman -S --noconfirm stow
  }

  cd "$DOTFILES"

  # Apply each package
  for pkg in "${PACKAGES[@]}"; do
    [ ! -d "$pkg" ] && continue

    info "Applying: $pkg"

    # Check for conflicts
    if stow --no --verbose=2 "$pkg" 2>&1 | grep -q "conflicts"; then
      warn "Conflicts in $pkg"
      echo "Options: 1) Skip  2) Overwrite  3) Adopt"
      read -rp "Choice (1-3): " choice

      case $choice in
      1) continue ;;
      2) stow --override="/.*/" --verbose=2 "$pkg" ;;
      3) stow --adopt --verbose=2 "$pkg" ;;
      *) continue ;;
      esac
    else
      stow --verbose=2 "$pkg"
    fi
  done

  log "Stow packages applied"
}

setup_hyprland() {
  stow hypr
}

# Main
main() {
  echo "=== Dotfiles Setup ==="

  backup_existing
  check_structure

  read -rp "Continue with setup? (y/N): " confirm
  [[ ! "$confirm" =~ ^[Yy]$ ]] && exit 0

  apply_stow
  setup_scripts
  setup_hyprland

  success "Setup complete!"
  info "Backup: $BACKUP_DIR"
  info "Restart your session for changes to take effect"
}

# Run
main "$@"
