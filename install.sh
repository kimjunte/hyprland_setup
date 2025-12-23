#!/bin/bash
set -euo pipefail

BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"
log() { echo -e "${BLUE}[*]${NC} $1"; }
ok() { echo -e "${GREEN}[✔]${NC} $1"; }
err() { echo -e "${RED}[!]${NC} $1"; }

log "Starting Hyprland setup (NO STOW, dotfiles preserved)..."

# ---------------------------------------------------------
# 0. Ensure Arch Linux
# ---------------------------------------------------------
if ! command -v pacman >/dev/null; then
  err "This installer is for Arch Linux only."
  exit 1
fi

# ---------------------------------------------------------
# 1. Install packages
# ---------------------------------------------------------
log "Installing base packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
  gcc keyd obsidian hyprland waybar vim neovim \
  obs-studio sshfs fastfetch noto-fonts-cjk \
  networkmanager torbrowser-launcher

ok "Packages installed."

# ---------------------------------------------------------
# 2. Install VSCode (AUR)
# ---------------------------------------------------------
log "Installing VSCode AUR package..."

if command -v yay >/dev/null; then
  yay -S --noconfirm visual-studio-code-bin
elif command -v paru >/dev/null; then
  paru -S --noconfirm visual-studio-code-bin
else
  log "Installing paru..."
  sudo pacman -S --noconfirm base-devel git
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
  paru -S --noconfirm visual-studio-code-bin
fi

ok "VSCode installed."

# ---------------------------------------------------------
# 3. Install keyd config
# ---------------------------------------------------------
log "Configuring keyd..."
sudo mkdir -p /etc/keyd
sudo cp -f keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
ok "keyd configured."

log "Removing old stow symlinks in HOME..."

if [[ -d "./dotfiles/home" ]]; then
  shopt -s dotglob
  for file in dotfiles/home/*; do
    name="$(basename "$file")"
    target="$HOME/$name"

    # If it is a symlink, remove it
    if [[ -L "$target" ]]; then
      echo " • Removing symlink: $target"
      rm -f "$target"
    fi
  done
  shopt -u dotglob
fi
# ---------------------------------------------------------
# 4. Install HOME dotfiles (dotfiles/home → $HOME)
# ---------------------------------------------------------
log "Copying HOME dotfiles..."

if [[ -d "./dotfiles/home" ]]; then
  shopt -s dotglob
  for file in dotfiles/home/*; do
    name="$(basename "$file")"
    cp -f "$file" "$HOME/$name"
    echo " → $file → $HOME/$name"
  done
  shopt -u dotglob
  ok "HOME dotfiles installed."
else
  err "dotfiles/home not found — skipping."
fi

# ---------------------------------------------------------
# 5. Install Hyprland + Waybar configs
# ---------------------------------------------------------
log "Installing Hyprland config..."
mkdir -p ~/.config/hypr
cp -rf hypr/* ~/.config/hypr/
ok "Hyprland config installed."

log "Installing Waybar config..."
mkdir -p ~/.config/waybar
cp -rf waybar/* ~/.config/waybar/
ok "Waybar config installed."

# ---------------------------------------------------------
# 6. Install NetworkManager dispatcher (dotfiles/etc → /etc)
# ---------------------------------------------------------
log "Installing NetworkManager dispatcher..."

SCRIPT_SRC="dotfiles/etc/NetworkManager/dispatcher.d/99-pihole-dns"
SCRIPT_DST="/etc/NetworkManager/dispatcher.d/99-pihole-dns"

if [[ -f "$SCRIPT_SRC" ]]; then
  sudo mkdir -p /etc/NetworkManager/dispatcher.d
  sudo cp -f "$SCRIPT_SRC" "$SCRIPT_DST"
  sudo chmod +x "$SCRIPT_DST"
  ok "Dispatcher installed: $SCRIPT_DST"
else
  err "Dispatcher script not found at $SCRIPT_SRC"
fi

# ---------------------------------------------------------
# 7. Enable NetworkManager
# ---------------------------------------------------------
log "Ensuring NetworkManager is active..."
sudo systemctl enable --now NetworkManager

ok "Setup complete! Reboot recommended."
