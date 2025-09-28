#!/bin/bash
# install all the dependencies
sudo apt install -y git build-essential libpam0g-dev libxcb-xkb-dev
# Clone the repository
git clone --recurse-submodules https://github.com/fairyglade/ly
# Change the directory to ly
cd ly
# Compile
sudo make
# Install Ly and the provided systemd service file
sudo make install installsystemd
# Enable the service
sudo systemctl enable ly.service
# If you need to switch between ttys after Ly's start
sudo systemctl disable getty@tty2.service
