#!/usr/bin/env bash
# Set up this machine from the repo: ./setup.sh [mac|devbox] [mise bootstrap args]
# The module defaults to mac on macOS and devbox on Linux, and is saved in
# .miserc.local.toml so a plain `mise bootstrap` here picks it up later.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES"

case "${1:-}" in
  mac|devbox) env="$1"; shift ;;
  *) env="$([ "$(uname)" = Darwin ] && echo mac || echo devbox)" ;;
esac
echo "env = [\"$env\"]" > .miserc.local.toml

command -v mise >/dev/null || curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

git submodule update --init --recursive
mise trust --quiet "$DOTFILES/mise.toml"
mise bootstrap "$@"

echo "Done. Open a new terminal to pick up the login shell and links."
