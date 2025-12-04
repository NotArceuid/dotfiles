#!/bin/bash

# Arch Linux System Installation Script
# Tailored for Hashed's dotfiles structure

set -e # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
USER_HOME="$HOME"
DOTFILES_DIR="$USER_HOME/dotfiles"
BACKUP_DIR="$USER_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Your existing dotfile packages from your structure
DOTFILE_PACKAGES=(
  "fastfetch"
  "fuzzel"
  "hypr"
  "kitty"
  "neofetch"
  "nvim"
  "nwg-look"
  "pavucontrol-qt"
  "Scripts"
  "Thunar"
  "waybar"
  "waypaper"
  "wayscriber"
  "xdg-desktop-portal"
  "yay"
  "yazi"
  "YouTube Music"
)

# Logging functions
log() {
  echo -e "${GREEN}[✓]${NC} $1"
}

info() {
  echo -e "${BLUE}[i]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[!]${NC} $1"
}

error() {
  echo -e "${RED}[✗]${NC} $1"
}

success() {
  echo -e "${CYAN}[✔]${NC} $1"
}

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root for package installation"
    info "Use: sudo $0"
    exit 1
  fi
}

# Check if running on Arch Linux
check_arch() {
  if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
    warn "This script is designed for Arch Linux"
    read -rp "Continue anyway? (y/N): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      exit 1
    fi
  fi
}

# Update system and install essential packages
update_system() {
  info "Updating system and installing essential packages..."
  pacman -Syu --noconfirm
  pacman -S --needed --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    sudo \
    stow \
    reflector
  log "System updated"
}

# Optimize mirrors with reflector
optimize_mirrors() {
  info "Optimizing package mirrors..."
  reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  log "Mirrors optimized"
}

# Install yay AUR helper
install_yay() {
  info "Installing yay AUR helper..."

  if command -v yay &>/dev/null; then
    log "yay is already installed"
    return
  fi

  # Create temporary directory for building yay
  YAY_TEMP_DIR=$(mktemp -d)
  cd "$YAY_TEMP_DIR"

  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm

  # Cleanup
  cd "$USER_HOME"
  rm -rf "$YAY_TEMP_DIR"

  log "yay installed successfully"
}

# Install packages with pacman
install_pacman_packages() {
  info "Installing pacman packages..."

  # Core packages matching your dotfiles
  core_packages=(
    discord
    fastfetch
    feh
    firefox-tridactyl
    fish
    foliate
    gamescope
    steam
    git
    github-cli
    gparted
    nvim
    htop
    btop
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    ibus
    ibus-pinyin
    kitty
    krita
    libreoffice
    pnpm
    nwg-look
    obs-studio
    qbittorrent
    reflector
    fuzzel
    stow
    sudo
    vlc
    gslapper
    waypaper
    waybar
    wine
    thunar
    telegram-desktop
    pavucontrol-qt
    yazi
    neofetch
  )

  # Additional packages that might be needed
  additional_packages=(
    python
    python-pip
    nodejs
    npm
    rustup
    clang
    gcc
    make
    cmake
    wl-clipboard
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    grim
    slurp
    swaybg
    polkit-gnome
    networkmanager
    bluez
    bluez-utils
    pulseaudio
    pulseaudio-bluetooth
    pavucontrol
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
  )

  info "Installing core packages..."
  pacman -S --needed --noconfirm "${core_packages[@]}"

  info "Installing additional packages..."
  pacman -S --needed --noconfirm "${additional_packages[@]}"

  log "All pacman packages installed"
}

# Install packages with yay
install_yay_packages() {
  info "Installing AUR packages..."

  if ! command -v yay &>/dev/null; then
    error "yay is not installed"
    exit 1
  fi

  aur_packages=(
    proton-ge-custom-bin
    youtube-music-bin
    wayscriber
  )

  for package in "${aur_packages[@]}"; do
    info "Installing $package..."
    yay -S --needed --noconfirm "$package" || warn "Failed to install $package"
  done

  log "AUR packages installation completed"
}

# Setup GNU Stow
setup_stow() {
  info "Setting up GNU Stow..."

  # Install stow if not already installed
  if ! command -v stow &>/dev/null; then
    pacman -S --noconfirm stow
  fi

  # Create stow configuration
  mkdir -p "$DOTFILES_DIR/.config"
  cat >"$DOTFILES_DIR/.stowrc" <<'EOF'
--verbose=2
--no-folding
--dotfiles
--target="$HOME"
EOF

  log "GNU Stow configured"
}

# Backup existing dotfiles
backup_dotfiles() {
  info "Backing up existing dotfiles..."

  mkdir -p "$BACKUP_DIR"

  # Backup each package's potential targets
  for package in "${DOTFILE_PACKAGES[@]}"; do
    # Get the actual directory name (handles spaces)
    package_dir=$(basename "$package")

    # Check what files this package would stow
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
      find "$DOTFILES_DIR/$package" -type f | while read -r file; do
        # Calculate target path
        relative_path="${file#$DOTFILES_DIR/$package/}"
        target_path="$USER_HOME/$relative_path"

        if [[ -e "$target_path" ]]; then
          backup_path="$BACKUP_DIR/$relative_path"
          mkdir -p "$(dirname "$backup_path")"
          cp -r "$target_path" "$backup_path"
          info "Backed up: $relative_path"
        fi
      done
    fi
  done

  # Backup common dotfiles
  common_dotfiles=(
    .bashrc .bash_profile .zshrc .zshenv
    .gitconfig .vimrc .tmux.conf
  )

  for dotfile in "${common_dotfiles[@]}"; do
    local source_path="$USER_HOME/$dotfile"
    if [[ -e "$source_path" ]]; then
      cp -r "$source_path" "$BACKUP_DIR/"
      info "Backed up: $dotfile"
    fi
  done

  log "Dotfiles backed up to $BACKUP_DIR"
}

# Verify dotfiles structure
verify_dotfiles_structure() {
  info "Verifying dotfiles structure..."

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi

  cd "$DOTFILES_DIR"

  # Check each package directory
  missing_packages=()
  for package in "${DOTFILE_PACKAGES[@]}"; do
    if [[ ! -d "$package" ]]; then
      missing_packages+=("$package")
    fi
  done

  if [[ ${#missing_packages[@]} -gt 0 ]]; then
    warn "Missing package directories:"
    for package in "${missing_packages[@]}"; do
      echo "  - $package"
    done
    read -rp "Continue anyway? (y/N): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      exit 1
    fi
  fi

  log "Dotfiles structure verified"
}

# Apply dotfiles with stow
apply_dotfiles_with_stow() {
  info "Applying dotfiles with GNU Stow..."

  cd "$DOTFILES_DIR"

  # Apply each package
  for package in "${DOTFILE_PACKAGES[@]}"; do
    if [[ ! -d "$package" ]]; then
      warn "Package directory not found: $package"
      continue
    fi

    info "Applying package: $package"

    # Check for conflicts first
    if stow --no --verbose=2 "$package" 2>&1 | grep -q "conflicts"; then
      warn "Conflicts detected for $package package"

      echo ""
      info "Conflicts found for $package:"
      stow --no --verbose=2 "$package" 2>&1 | grep "conflicts" | head -5

      read -rp "Choose action: [S]kip, [B]ackup and replace, [C]ontinue with adopt? (s/b/c): " action

      case $action in
      [Ss]*)
        warn "Skipping $package package"
        continue
        ;;
      [Bb]*)
        # Create package-specific backup
        PKG_BACKUP_DIR="$BACKUP_DIR/$package-$(date +%H%M%S)"
        mkdir -p "$PKG_BACKUP_DIR"

        # Backup conflicting files
        stow --no --verbose=2 "$package" 2>&1 |
          grep "conflicts" |
          sed 's/.*conflicts with //' |
          while read -r conflict; do
            if [[ -e "$USER_HOME/$conflict" ]]; then
              mkdir -p "$(dirname "$PKG_BACKUP_DIR/$conflict")"
              cp -r "$USER_HOME/$conflict" "$PKG_BACKUP_DIR/$conflict"
              info "Backed up conflict: $conflict"
            fi
          done

        # Apply with override
        stow --override="/.*/" --verbose=2 "$package"
        ;;
      [Cc]*)
        # Use adopt mode (move existing files to package directory)
        stow --adopt --verbose=2 "$package"
        ;;
      *)
        warn "Invalid choice, skipping $package"
        continue
        ;;
      esac
    else
      # No conflicts, proceed normally
      stow --verbose=2 "$package"
    fi
  done

  # Handle Scripts directory separately if it's not a stow package
  if [[ -d "Scripts" ]]; then
    info "Setting up Scripts directory..."
    if [[ ! -d "$USER_HOME/.local/bin" ]]; then
      mkdir -p "$USER_HOME/.local/bin"
    fi

    # Make scripts executable and link/copy them
    find "Scripts" -type f -name "*.sh" -o -name "*.py" | while read -r script; do
      chmod +x "$script"
      script_name=$(basename "$script")
      ln -sf "$(realpath "$script")" "$USER_HOME/.local/bin/${script_name%.*}" ||
        cp "$script" "$USER_HOME/.local/bin/${script_name%.*}"
    done
  fi

  log "Dotfiles applied successfully"
}

# Setup shell and terminal
setup_shell() {
  info "Setting up shell environment..."

  # Setup fish shell
  if command -v fish &>/dev/null; then
    # Check if fish is already the default shell
    if [[ "$SHELL" != *"fish"* ]]; then
      # Check if fish is in /etc/shells
      if ! grep -q "$(which fish)" /etc/shells; then
        echo "$(which fish)" | sudo tee -a /etc/shells
      fi
      chsh -s "$(which fish)"
      log "Default shell changed to fish"
    fi

    # Setup fisher if not installed
    if [[ ! -f "$USER_HOME/.config/fish/functions/fisher.fish" ]]; then
      info "Installing fisher plugin manager..."
      fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fi
  fi

  # Setup bashrc if fish is not installed
  if ! command -v fish &>/dev/null && [[ ! -f "$USER_HOME/.bashrc" ]]; then
    cat >"$USER_HOME/.bashrc" <<'EOF'
# Custom bashrc
export EDITOR=nvim
export VISUAL=nvim

# Aliases
alias ls='exa --icons'
alias ll='exa -la --icons'
alias vim='nvim'
alias grep='grep --color=auto'
alias pacman='sudo pacman'
alias update='sudo pacman -Syu'

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Enable starship prompt if installed
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
EOF
  fi

  log "Shell setup completed"
}

# Setup development environment
setup_development() {
  info "Setting up development environment..."

  # Setup Rust if installed
  if command -v rustup &>/dev/null; then
    rustup default stable
    log "Rust configured"
  fi

  # Setup pnpm
  if command -v pnpm &>/dev/null; then
    # Setup pnpm store
    export PNPM_HOME="$USER_HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    log "pnpm configured"
  fi

  # Setup git
  if command -v git &>/dev/null && [[ ! -f "$USER_HOME/.gitconfig" ]]; then
    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"
    git config --global core.editor nvim
    git config --global init.defaultBranch main
    log "Git configured"
  fi

  log "Development environment setup completed"
}

# Setup desktop environment
setup_desktop() {
  info "Setting up desktop environment..."

  # Enable NetworkManager
  if command -v systemctl &>/dev/null && pacman -Q networkmanager &>/dev/null; then
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
    log "NetworkManager enabled"
  fi

  # Enable bluetooth
  if command -v systemctl &>/dev/null && pacman -Q bluez &>/dev/null; then
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    log "Bluetooth enabled"
  fi

  # Setup IBus for Chinese input
  if command -v ibus &>/dev/null; then
    # Create environment file for IBus
    ENV_FILE="$USER_HOME/.config/environment.d/ibus.conf"
    mkdir -p "$(dirname "$ENV_FILE")"
    cat >"$ENV_FILE" <<'EOF'
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
EOF
    log "IBus input method configured"
  fi

  # Make sure essential directories exist
  mkdir -p "$USER_HOME/.config"
  mkdir -p "$USER_HOME/.local/bin"
  mkdir -p "$USER_HOME/.local/share"

  log "Desktop environment setup completed"
}

# Post-installation configuration
post_install() {
  info "Running post-installation configuration..."

  # Set ownership of user directories
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME"

  # Setup yay if present in dotfiles
  if [[ -d "$DOTFILES_DIR/yay" ]]; then
    info "Configuring yay..."
    # Copy yay configuration if it exists
    if [[ -f "$DOTFILES_DIR/yay/yay.json" ]]; then
      cp "$DOTFILES_DIR/yay/yay.json" "$USER_HOME/.config/yay/"
    fi
  fi

  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  log "Post-installation configuration completed"
}

# Display installation summary
show_summary() {
  success "╔══════════════════════════════════════════╗"
  success "║      INSTALLATION COMPLETED!             ║"
  success "╚══════════════════════════════════════════╝"
  echo ""
  info "Installed Packages:"
  echo "  ${CYAN}•${NC} Desktop: Hyprland, waybar, kitty, fuzzel"
  echo "  ${CYAN}•${NC} Applications: Discord, Firefox, Steam, OBS, VLC"
  echo "  ${CYAN}•${NC} Development: Git, nvim, pnpm, GitHub CLI"
  echo "  ${CYAN}•${NC} Utilities: fastfetch, yazi, Thunar, yay"
  echo ""
  info "Dotfiles Applied:"
  for package in "${DOTFILE_PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
      echo "  ${GREEN}✓${NC} $package"
    fi
  done
  echo ""
  info "Backup Location:"
  echo "  $BACKUP_DIR"
  echo ""
  warn "Important Notes:"
  echo "  1. Log out and log back in for shell changes to take effect"
  echo "  2. Check ~/.config/ for your configuration files"
  echo "  3. Scripts are available in ~/.local/bin/"
  echo ""
  info "To start Hyprland:"
  echo "  If using a display manager: Select Hyprland"
  echo "  If using TTY: Type 'Hyprland'"
  echo ""
}

# Clean up function
cleanup() {
  info "Cleaning up..."
  # Remove temporary files if any
  rm -rf /tmp/yay-build-*
  log "Cleanup completed"
}

# Main installation function
install_all() {
  echo ""
  success "Starting Arch Linux Installation Script"
  echo "Dotfiles directory: $DOTFILES_DIR"
  echo ""

  check_root
  check_arch
  update_system
  optimize_mirrors
  install_yay
  install_pacman_packages
  install_yay_packages
  backup_dotfiles
  verify_dotfiles_structure
  setup_stow
  apply_dotfiles_with_stow
  setup_shell
  setup_development
  setup_desktop
  post_install
  cleanup

  echo ""
  show_summary
}

# Individual functions for modular execution
case "${1:-}" in
"--update-only")
  check_root
  update_system
  optimize_mirrors
  ;;
"--install-yay")
  check_root
  install_yay
  ;;
"--install-packages")
  check_root
  install_pacman_packages
  install_yay_packages
  ;;
"--setup-dotfiles")
  if [[ $EUID -eq 0 ]]; then
    warn "Running dotfiles setup as root may cause permission issues"
    read -rp "Continue as root? (y/N): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      exit 1
    fi
  fi
  backup_dotfiles
  verify_dotfiles_structure
  setup_stow
  apply_dotfiles_with_stow
  setup_shell
  setup_development
  ;;
"--post-install")
  check_root
  setup_desktop
  post_install
  ;;
"--help" | "-h")
  cat <<EOF
Arch Linux System Installation Script
Tailored for Hashed's dotfiles structure

Usage: sudo $0 [OPTION]

Options:
  --update-only        Update system and optimize mirrors only
  --install-yay        Install yay AUR helper only
  --install-packages   Install all packages (pacman + AUR)
  --setup-dotfiles     Setup dotfiles with GNU Stow only (run as user)
  --post-install       Run post-installation configuration only
  --help, -h           Show this help message

Without any option, runs complete installation.

Examples:
  sudo $0 --install-packages
  $0 --setup-dotfiles
EOF
  exit 0
  ;;
*)
  install_all
  ;;
esac
