#!/usr/bin/env bash

set -euo pipefail


source "$(dirname "$0")/../lib/logger.sh"

info "DNF Configuration"


DNF_CONF="/etc/dnf/dnf.conf"

#pick the fastes available mirror automatically
if ! sudo grep -q "^fastestmirror=" "$DNF_CONF"; then
    echo "fastestmirror=True" | sudo tee -a "$DNF_CONF" > /dev/null
fi

#lets dnf grab up to 10 packages at once instead of going one at the time
if ! sudo grep -q "^max_parallel_downloads=" "$DNF_CONF"; then
    echo "max_parallel_downloads=10" | sudo tee -a "$DNF_CONF" > /dev/null
fi


#hitting enter on a confirmation prompt accepts instead of declines, which saves a lot of typing
if ! sudo grep -q "^defaultyes=" "$DNF_CONF"; then
    echo "defaultyes=True" | sudo tee -a "$DNF_CONF" > /dev/null
fi

#keep downloaded packages around so reinstalls dont redownload the same thing
if ! sudo grep -q "^keepcache=" "$DNF_CONF"; then
    echo "keepcache=True" | sudo tee -a "$DNF_CONF" > /dev/null
fi

success "DNF configured succesfully"