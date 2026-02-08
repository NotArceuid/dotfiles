#!/bin/bash

set -e

USER_HOME="$1"
DOTFILES_DIR="$USER_HOME/.dotfiles"
BACKUP_DIR="$USER_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root for package installation"
    echo "Use: sudo $0"
    exit 1
  fi
}

update_system() {
  echo "Updating system and installing essential packages..."
  pacman -Syu --noconfirm
  pacman -S --needed --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    sudo \
    stow \
    reflector
  echo "System updated"
}

optimize_mirrors() {
  echo "Optimizing package mirrors..."
  reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  echo "Mirrors optimized"
}

install_pacman_packages() {
  echo "Installing pacman packages..."

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
    sudo
    vlc-plugin-ffmpeg
    vlc
    waybar
    wine
    thunar
    telegram-desktop
    yazi
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

  echo "Installing core packages..."
  pacman -S --needed --noconfirm "${core_packages[@]}"
}

install_all() {
  echo "Starting Arch Linux Installation Script"
  echo "Dotfiles directory: $DOTFILES_DIR"

  check_root
  update_system
  optimize_mirrors
  install_pacman_packages
  cleanup
}

install_all
