#!/bin/bash
set -euo pipefail

echo "[*] Starting Hyprland config setup..."

# ---------------------------------------------------------
# 0. Detect Arch Linux
# ---------------------------------------------------------
if ! command -v pacman &>/dev/null; then
  echo "[!] This installer is made for Arch Linux."
  exit 1
fi

# ---------------------------------------------------------
# 1. Install required packages
# ---------------------------------------------------------
echo "[*] Installing packages..."

sudo pacman -Syu --noconfirm

sudo pacman -S --noconfirm \
  gcc \
  keyd \
  obsidian \
  hyprland \
  waybar \
  vim \
  neovim \
  obs-studio \
  sshfs \
  fastfetch \
  noto-fonts-cjk \
  stow \
  networkmanager

# ---------------------------------------------------------
# 2. Install VSCode from AUR
# ---------------------------------------------------------
echo "[*] Installing VSCode (visual-studio-code-bin)..."

if command -v yay &>/dev/null; then
  yay -S --noconfirm visual-studio-code-bin
elif command -v paru &>/dev/null; then
  paru -S --noconfirm visual-studio-code-bin
else
  echo "[*] No AUR helper found. Installing paru..."
  sudo pacman -S --noconfirm base-devel git

  git clone https://aur.archlinux.org/paru.git /tmp/paru
  cd /tmp/paru
  makepkg -si --noconfirm
  cd -

  paru -S --noconfirm visual-studio-code-bin
fi

# ---------------------------------------------------------
# 3. Enable keyd
# ---------------------------------------------------------
echo "[*] Setting up keyd..."
sudo mkdir -p /etc/keyd
sudo cp -f keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# ---------------------------------------------------------
# 4. Deploy user configs (Hyprland, Waybar, Dotfiles) using stow
# ---------------------------------------------------------
echo "[*] Deploying dotfiles with stow..."

mkdir -p ~/.config

# Home dotfiles
stow --verbose --restow --target="$HOME" dotfiles

# Hyprland configs
mkdir -p ~/.config/hypr
cp -r hypr/* ~/.config/hypr/

# Waybar configs
mkdir -p ~/.config/waybar
cp -r waybar/* ~/.config/waybar/

# ---------------------------------------------------------
# 5. Install NetworkManager dispatcher script via stow
# --------------------------------------------------------------
if [[ -d "dotfiles/networkmanager" ]]; then
  echo "[*] Applying NetworkManager dispatcher script (Pi-hole)..."

  …/NetworkManager/dispatcher.d🔒 ❯ ls
  Permissions Size User Date Modified Name
  drwxr-xr-x - root 17 Nov 16:58  no-wait.d
  drwxr-xr-x - root 17 Nov 16:58  pre-down.d
  drwxr-xr-x - root 17 Nov 16:58  pre-up.d
  lrwxrwxrwx - root 9 Dec 00:48 󰡯 99-pihole-dns - >../../../home/kimjunte/hyprland_setup/dotfiles/networkmanager/etc/NetworkManager/dispatcher.d/99-pihole-dns

  …/NetworkManager/dispatcher.d🔒 ❯ cat 99-pihole-dns
  #!/bin/bash

  # SSID that should use Pi-hole DNS
  TARGET_SSID="VM6613807"
  PIHOLE_DNS="192.168.0.201"

  IFACE="$1"
  STATUS="$2"

  # Only run for wifi
  if [[ "$IFACE" != wlp* && "$IFACE" != wlan* ]]; then
    exit 0
  fi

  CURRENT_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)

  if [[ "$STATUS" == "up" && "$CURRENT_SSID" == "$TARGET_SSID" ]]; then
    nmcli connection modify "$TARGET_SSID" ipv4.ignore-auto-dns yes
    nmcli connection modify "$TARGET_SSID" ipv4.dns "$PIHOLE_DNS"
    logger "Pi-hole DNS applied for $TARGET_SSID"
  else
    nmcli connection modify "$TARGET_SSID" ipv4.ignore-auto-dns no
    nmcli connection modify "$TARGET_SSID" ipv4.dns ""
    logger "Pi-hole DNS removed (SSID changed)"
  fi

  …/NetworkManager/dispatcher.d🔒 ❯ sudo stow \
    --verbose \
    --restow \
    --dir=dotfiles \
    --target=/ \
    networkmanager

  sudo chmod +x /etc/NetworkManager/dispatcher.d/99-pihole-dns
else
  echo "[!] No networkmanager config found in dotfiles/ — skipping."
fi
# ---------------------------------------------------------
# 6. Enable NetworkManager (if not already)
# ---------------------------------------------------------
echo "[*] Ensuring NetworkManager is running..."
sudo systemctl enable --now NetworkManager

echo "[✓] Installation complete! Re-login or reboot recommended."
