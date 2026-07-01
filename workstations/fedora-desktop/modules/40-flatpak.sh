#!/usr/bin/env bash


source "$(dirname "$0")/../lib/logger.sh"

info "Flatpak and Flathub"

sudo dnf install -y flatpak


flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


success "Flatpak and flathub configured succesfully"

