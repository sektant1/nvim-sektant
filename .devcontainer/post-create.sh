#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

mkdir -p "$(dirname "$config_dir")" "$HOME/.local/share" "$HOME/.local/state" "$HOME/.cache"

if [ -e "$config_dir" ] && [ ! -L "$config_dir" ]; then
  mv "$config_dir" "${config_dir}.bak.$(date +%Y%m%d%H%M%S)"
fi

ln -sfn "$PWD" "$config_dir"

nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstallSync" +qa
