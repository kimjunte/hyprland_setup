#!/bin/bash

set -e

echo "[*] Starting Hypland config setup..."

# Install required packages (example for Arch-based systems)
if command -v pacman &>/dev/null; then
  echo "[*] Installing packages..."
  # download software I use
  sudo pacman -S --noconfirm gcc keyd obsidian hyprland waybar vim obs-studio neovim
  # download korean
  sudo pacman -S --noconfirm noto-fonts-cjk
  # download sshfs
  sudo pacman -S --noconfirm sshfs
  # neofetch
  sudo pacman -S --noconfim fastfetch
fi

echo "[*] Installing VSCode (visual-studio-code-bin)..."

if command -v yay &>/dev/null; then
  echo "[*] Using yay..."
  yay -S --noconfirm visual-studio-code-bin

elif command -v paru &>/dev/null; then
  echo "[*] Using paru..."
  paru -S --noconfirm visual-studio-code-bin

else
  echo "[*] No AUR helper found. Installing manually..."
  sudo pacman -S --noconfirm base-devel git

  git clone https://aur.archlinux.org/visual-studio-code-bin.git /tmp/vscode-bin
  cd /tmp/vscode-bin
  makepkg -si --noconfirm
  cd -
fi

# Copy keyd config
echo "[*] Setting up keyd..."
sudo mkdir -p /etc/keyd
sudo cp keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# Copy Hyprland config
echo "[*] Setting up Hyprland config..."
mkdir -p ~/.config/hypr
cp -r hypr/* ~/.config/hypr/

# Copy Waybar config
echo "[*] Setting up Waybar config..."
mkdir -p ~/.config/waybar
cp -r waybar/* ~/.config/waybar/

echo "[*] Setting up dot config..."
cp -r dotfiles/.vimrc ~/.vimrc
cp dotfiles/.bashrc ~/.bashrc
cp dotfiles/.gitconfig ~/.gitconfig

echo "[✓] Setup complete."
