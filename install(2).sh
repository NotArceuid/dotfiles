install_yay_packages() {
  echo "Installing AUR packages..."

  if ! command -v yay &>/dev/null; then
    echo "yay is not installed"
    echo "Installing yay"

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..

    exit 1
  fi

  aur_packages=(
    proton-ge-custom-bin
    youtube-music-for-desktop-bin
    wayscriber
    gslapper
    htop-vim
    waypaper
  )

  for package in "${aur_packages[@]}"; do
    echo "Installing $package..."
    yay -S --needed --noconfirm "$package" || warn "Failed to install $package"
  done

  echo "AUR packages installation completed"
}

install_yay_packages
