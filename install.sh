#!/bin/bash

set -e

echo "[*] Starting Hypland config setup..."

# Install required packages (example for Arch-based systems)
if command -v pacman &> /dev/null; then
    echo "[*] Installing packages..."
    sudo pacman -S --noconfirm keyd obsidian hyprland
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

echo "[✓] Setup complete."

