#!/usr/bin/env bash

#Fedora ships with a lot of free and non-free packages 
#disabled by default for licensing reasons. 

#RPM Fusion is what fixes that, and you really want this enabled if you plan to use 
#Steam, Discord, multimedia codecs, NVIDIA drivers, 
#or pretty much any of the mainstream useful stuff.


info "RPM Fusion"

source "$(dirname "$0")/../lib/logger.sh"

#installing rpm fusion
if dnf repolist | grep -q "rpmfusion-free"; then
    success "RPM Fusion already installed. Skipping..."
else
    sudo dnf install -y  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi



# resolve packaging bug where Fedora enables the Rawhide repo 
# (which is for Fedora development, not 44) and disables the proper Fedora 44 free repo
if dnf repolist --all | grep -i "rpmfusion-free-rawhide" | grep -q "enabled"; then

    info "Applying Fedora 44 RPM Fusion bug fix (disabling rawhide)..."
    
    sudo dnf config-manager setopt rpmfusion-free.enabled=1
    sudo dnf config-manager setopt rpmfusion-free-updates.enabled=1
    sudo dnf config-manager setopt rpmfusion-free-rawhide.enabled=0

    success "RPM Fusion Rawhide bug fix applied successfully!"
fi

if dnf repolist --all | grep -i "fedora-cisco-openh264" | grep -q "disabled"; then
    info "Enabling Cisco openh264 repository..."
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
    success "Cisco openh264 enabled!"
fi



success "RPM Fusion installed succesfully"