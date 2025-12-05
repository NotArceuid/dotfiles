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

post_install() {
  info "Running post-installation configuration..."

  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME"

  if [[ -d "$DOTFILES_DIR/yay" ]]; then
    info "Configuring yay..."
    if [[ -f "$DOTFILES_DIR/yay/yay.json" ]]; then
      cp "$DOTFILES_DIR/yay/yay.json" "$USER_HOME/.config/yay/"
    fi
  fi

  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  log "Post-installation configuration completed"
}

post_install
