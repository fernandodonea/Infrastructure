#!/usr/bin/env bash

source "$(dirname "$0")/../lib/logger.sh"

info "Configuring multimedia codecs"


#swap crippled ffmpeg-free with full ffmpeg
info "Swapping ffmpeg-free with ffmpeg..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing


#update the multimedia group so things like hardware acceleration work
info "Upgrading core group..."
sudo dnf group upgrade -y core

success "Codecs and media configures succesfully"



