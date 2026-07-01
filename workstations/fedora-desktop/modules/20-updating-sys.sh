#!/usr/bin/env bash


source "$(dirname "$0")/../lib/logger.sh"

info "Updating the system..."


sudo dnf -y update

success "System updated succesfully!"
