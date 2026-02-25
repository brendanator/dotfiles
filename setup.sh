#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"

# Install mise
if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install stow
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  if [[ "$(uname)" == "Darwin" ]]; then
    brew install stow
  else
    sudo apt-get install -y stow
  fi
fi

# Init submodules (prezto)
cd "$DOTFILES"
git submodule update --init --recursive

# Stow all packages (--adopt absorbs existing files, then we restore repo versions)
echo "Stowing packages..."
for dir in */; do
  stow --adopt -v "$dir" 2>&1 || echo "WARN: failed to stow $dir"
done
git checkout .

# Install mise tools
echo "Installing tools via mise..."
mise install

echo "Done. Open a new terminal to verify."
