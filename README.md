# dotfiles

Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```bash
git clone --recursive https://github.com/brendanator/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
```

## Packages

atuin, bash, bin, bun, claude, direnv, gh, ghostty, git,
graphite, karabiner, lazygit, mise, npm, nvim, pgcli, pnpm,
readline, ripgrep, starship, tmux, tmuxinator, uv, zed, zsh

## Usage

```bash
cd ~/.dotfiles

# Add a new config
mkdir -p <package>/.config/<tool>
mv ~/.config/<tool>/config <package>/.config/<tool>/
stow <package>

# Re-stow after pulling changes
stow -R */

# Remove a package's symlinks
stow -D <package>
```
