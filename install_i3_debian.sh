#!/bin/bash

# GIT CURL
sudo apt install -y git curl

# xorg display server installation
sudo apt install -y xserver-xorg-core xinit

# Install i3
sudo apt install -y i3

# Installation for Appearance management
sudo apt install -y lxappearance

# File Manager
sudo apt install -y thunar thunar-archive-plugin

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
sudo apt install -y network-manager xfce4-power-manager rofi dunst polybar picom unzip playerctl scrot xdg-user-dirs-gtk

# AmneziaVPN packages
sudo apt install -y libxcb-cursor0 libxcb-xinerama0

# Additional Software
sudo apt install -y curl ffmpeg mpv micro nala moc

# Install fonts
sudo apt install -y fonts-font-awesome fonts-firacode

# Install Display Manager
sudo apt install -y slim

# Create folders in user directory
xdg-user-dirs-update

#Additional
source onlyoffice-install-debian.sh
source wifi-macbookpro.sh
source zen-browser-install.sh

# Themes
mkdir /home/st/.themes
cd /home/st/.themes && git clone https://github.com/vinceliuice/Orchis-theme.git && cd Orchis-theme/ && sudo bash ./install.sh -c dark -s compact --tweaks dracula --round 1 && cd

#Afterinstall
sudo \cp --force ~/i3wm-dots/90-touchpad.conf /etc/X11/xorg.conf.d/
\cp -rp --force ~/i3wm-dots/moc/ ~
\cp --force .xinitrc ~
\cp --force .Xresources ~
\cp -rp --force ~/i3wm-dots/alacritty/ ~/.config/
\cp -rp --force ~/i3wm-dots/dunst/ ~/.config/
\cp -rp --force ~/i3wm-dots/i3/ ~/.config/
\cp -rp --force ~/i3wm-dots/polybar/ ~/.config/
\cp -rp --force ~/i3wm-dots/rofi/ ~/.config/

# Finish Clean
sudo apt autopurge -y

echo "Setup Complete! Please, reboot your computer!"
