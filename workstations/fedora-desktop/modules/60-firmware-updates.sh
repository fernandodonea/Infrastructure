#!/usr/bin/env bash


set -euo pipefail

source "$(dirname "$0")/../lib/logger.sh"

info "Updating the firmware..."


fwupdmgr refresh --force
fwupdmgr get-devices
fwupdmgr get-updates
fwupdmgr update -y



success "Firmware updated succesfully!"
