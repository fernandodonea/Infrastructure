#!/bin/bash


set -e #stop de script if you get any errors


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/lib/logger.sh"


if [[ $EUID -eq 0 ]]; then
    error "Dont run this script as sudo"
fi

info "Starting configuring Fedora 44 KDE Plasma..."



for script in "$BASE_DIR"/modules/*.sh; do
    if [ -x "$script" ]; then
        info "Running module: $(basename "$script")..."
        "$script"
    else
        error "Module $script doesnt have execution permission"
    fi
done

success "All modules finished."


