#!/bin/bash

echo "❄️ Installing Winter Rice Configuration..."

# Backup existing configs
for config in hypr waybar rofi swaylock kitty dunst; do
    if [ -d "$HOME/.config/$config" ]; then
        echo "Backing up existing $config config..."
        mv "$HOME/.config/$config" "$HOME/.config/$config.backup.$(date +%Y%m%d_%H%M%S)"
    fi
done

# Copy new configs
echo "Installing new configurations..."
cp -r configs/* ~/.config/

# Make scripts executable
chmod +x ~/.config/waybar/scripts/weather.py
chmod +x ~/.config/waybar/scripts/power-menu/powermenu.sh

echo "✅ Installation complete!"
echo "🎨 Don't forget to:"
echo "   - Set your wallpaper in hyprland.conf"
echo "   - Reload Hyprland (Super+Shift+R)"
echo "   - Check that all fonts are installed"