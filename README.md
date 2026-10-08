# dotfiles

Personal config, linked into `$HOME` by [mise's dotfiles](https://mise.jdx.dev/dotfiles.html).
Each top-level directory is a group in `mise.toml`; its tree mirrors `$HOME`, and
mise symlinks each file git tracks in it into place.

## Install

```bash
git clone --recursive https://github.com/brendanator/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
```

`setup.sh` installs mise and zsh, links the configs with `dotfiles apply`,
installs the tools from `~/.config/mise/config.toml`, and makes zsh the login shell.
It also converts a home that GNU Stow set up: folded directory links become real
directories, and `~/.claude/settings.json` becomes a real file.

## Packages

atuin, bash, bin, bun, claude, direnv, gh, ghostty, git,
graphite, karabiner, lazygit, mise, npm, nvim, pgcli, pnpm,
readline, ripgrep, starship, tmux, tmuxinator, uv, zed, zsh

A machine links them all, unless a gitignored `~/.dotfiles/mise.local.toml` picks some:

```toml
[bootstrap]
dotfile_groups = ["zsh", "git", "nvim"]
```

### Claude settings

`~/.claude/settings.json` is a real file, not a symlink. mise merges the keys in
`claude/.claude/settings.json` into it and leaves every other key alone, so a
machine keeps its own keys (e.g. a private `autoMode` block) there.
A repo-owned key changed locally (say by `/model`) is set back on the next
apply; change it in the repo to keep it. Removing a key from the repo file does
not remove it from machines.

## Usage

```bash
cd ~/.dotfiles

# Add a new config: move it into a group's tree, commit it (groups link only
# files git tracks), then link it
mkdir -p <package>/.config/<tool>
mv ~/.config/<tool>/config <package>/.config/<tool>/
git add <package>
dotfiles apply

# A new package also needs a [dotfile_groups.<package>] table in mise.toml

# Link everything (dotfiles pull does this after pulling)
dotfiles apply

# Preview, or see what is out of place
mise dot apply --dry-run
mise dot status

# Remove a package's links: delete its group from mise.toml, then
mise dot apply --prune
```

## Syncing

```bash
dotfiles push          # auto-commit and push local changes
dotfiles pull          # pull, then dotfiles apply
dotfiles apply         # link the configs (mise dot apply)
dotfiles sync-remotes  # push, then `dotfiles pull` over ssh on every remote
```

`sync-remotes` reads hosts from `~/.dotfiles/remotes` (gitignored, one ssh host
per line, `#` comments allowed), or takes them as arguments:
`dotfiles sync-remotes ape-devbox-brendan-1`.
