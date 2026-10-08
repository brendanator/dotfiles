#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
export DOTFILES  # read by the dotfiles script

echo "Installing dotfiles from $DOTFILES"

# Install mise
if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install zsh
if [[ "$(uname)" == "Darwin" ]]; then
  command -v zsh &>/dev/null || brew install zsh
else
  command -v zsh &>/dev/null || sudo apt-get install -y zsh
fi

# Init submodules (prezto)
cd "$DOTFILES"
git submodule update --init --recursive

# Link the configs (groups in mise.toml); this also converts a home set up by stow.
echo "Linking configs via mise..."
"$DOTFILES/bin/.local/bin/dotfiles" apply

# Install mise tools (from the global config just linked)
echo "Installing tools via mise..."
mise install

# Set zsh as default shell
if [[ "$SHELL" != */zsh ]]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

echo "Done. Open a new terminal to verify."
