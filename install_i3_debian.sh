#!/bin/bash

# xorg display server installation
sudo apt install -y xorg
# Install i3
sudo apt install -y i3

# Network Manager & wireguard
sudo apt install -y wireguard-tools openresolv

# Installation for Appearance management
sudo apt install -y lxappearance

# File Manager
sudo apt install -y pcmanfm

# Network File Tools/System Events
sudo apt install -y dialog acpi acpid gvfs-backends arandr

sudo systemctl enable acpid

# Terminal
sudo apt install -y alacritty

# Sound packages
sudo apt install -y pulseaudio pavucontrol

# Printing and bluetooth (if needed)
sudo apt install -y bluez

sudo systemctl enable bluetooth

# Desktop background browser/handler 
sudo apt install -y feh

# Packages needed i3 after installation
sudo apt install -y xfce4-power-manager numlockx rofi dunst file-roller polybar picom unzip playerctl scrot tumbler xdg-user-dirs-gtk

# Additional Software
sudo apt install -y curl ffmpeg mpv micro git

# Install fonts
sudo apt install -y fonts-font-awesome fonts-jetbrains-mono fonts-firacode

# Install Display Manager
sudo apt install -y slim

# Finish Clean
sudo apt autopurge -y

# Create folders in user directory
xdg-user-dirs-update

# Установка драйвера WiFi Macbook
echo ""
read -p ">>> Установить драйвер WiFi для Macbook? (y/n) " choice
echo ""
if [ "$choice" == "y" ]; then
sudo apt install -y linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
sudo modprobe wl
echo ""
echo "| Драйвер установлен"
else
echo "| Установка пропущена"
fi

# Themes
mkdir /home/st/.themes
cd /home/st/.themes && git clone https://github.com/vinceliuice/Orchis-theme.git && cd Orchis-theme/ && sudo bash ./install.sh -c dark -s compact --tweaks dracula --round 1 && cd

echo "Setup Complete! Please, reboot your computer!"
