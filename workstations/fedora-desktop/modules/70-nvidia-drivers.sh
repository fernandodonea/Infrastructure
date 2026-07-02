#!/usr/bin/env bash

set -euo pipefail


source "$(dirname "$0")/../lib/logger.sh"

info "Installing Nvidia Drivers"



if ! lspci | grep -i nvidia &> /dev/null; then
    success "No Nvidia detected. Skipping"
    exit 0
fi



if rpm -qa | grep -q akmod-nvidia; then
    success "Nvidia drivers already installed"
else
    sudo dnf install akmod-nvidia -y

    info "We wait for the kernel module to compile"
    sudo akmods --force
fi


