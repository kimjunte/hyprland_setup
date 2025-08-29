#!/bin/bash

set -e

echo "[*] Starting Hypland config setup..."

# Install required packages (example for Arch-based systems)
if command -v pacman &>/dev/null; then
  echo "[*] Installing packages..."
  # download software I use
  sudo pacman -S --noconfirm keyd obsidian hyprland waybar vim visual-studio-code-bin obs-studio neovim
  # download korean
  sudo pacman -S --noconfirm noto-fonts-cjk
fi

# Copy keyd config
echo "[*] Setting up keyd..."
sudo mkdir -p /etc/keyd
sudo cp keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# Copy hyprland config
echo "[*] Setting up Hyprland config..."
mkdir -p ~/.config/hypr
cp -r hypr/* ~/.config/hypr/

# Copy wayland config
echo "[*] Setting up Wayland config..."
mkdir -p ~/.config/waybar
cp -r waybar/* ~/.config/waybar/

echo "[*] Setting up Vim config..."
cp -r vim/.vimrc ~/.vimrc
cp -r vim/.bashrc ~/.bashrc

echo "[✓] Setup complete."
