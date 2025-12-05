#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

USER_HOME="$1"
DOTFILES_DIR="$USER_HOME/.dotfiles"
BACKUP_DIR="$USER_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

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

check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root for package installation"
    info "Use: sudo $0"
    exit 1
  fi
}

check_arch() {
  if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
    warn "This script is designed for Arch Linux"
    read -rp "Continue anyway? (y/N): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      exit 1
    fi
  fi
}

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

optimize_mirrors() {
  info "Optimizing package mirrors..."
  reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  log "Mirrors optimized"
}

install_pacman_packages() {
  info "Installing pacman packages..."

  core_packages=(
    discord
    fastfetch
    feh
    firefox
    unzip
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
    fcitx5
    fcitx5-chinese-input
    cowsay
    lolcat
    hyprshot
    tumbler
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    ibus
    ibus-libpinyin
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
    vlc-plugin-ffmpeg
    vlc
    waybar
    wine
    thunar
    telegram-desktop
    yazi
  )

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

install_all() {
  echo ""
  success "Starting Arch Linux Installation Script"
  echo "Dotfiles directory: $DOTFILES_DIR"
  echo ""

  check_root
  check_arch
  update_system
  optimize_mirrors
  install_pacman_packages
  cleanup

  echo ""
  show_summary
}
