# Install packages with yay
install_yay_packages() {
  info "Installing AUR packages..."

  if ! command -v yay &>/dev/null; then
    error "yay is not installed"
    exit 1
  fi

  aur_packages=(
    fortune-mod-off
    proton-ge-custom-bin
    youtube-music-for-desktop-bin
    wayscriber
    gslapper
    htop-vim
    waypaper
  )

  for package in "${aur_packages[@]}"; do
    info "Installing $package..."
    yay -S --needed --noconfirm "$package" || warn "Failed to install $package"
  done

  log "AUR packages installation completed"
}

install_yay_packages
