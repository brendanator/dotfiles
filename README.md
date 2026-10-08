# dotfiles

Personal config, linked into `$HOME` by [mise's dotfiles](https://mise.jdx.dev/dotfiles.html).
Each top-level directory is a group in `mise.toml`; its tree mirrors `$HOME`, and
mise symlinks each file git tracks in it into place.

## New machine

`mise bootstrap` sets a machine up from this repo and keeps it that way: run it
again after any change. What it does beyond linking configs comes from the
machine's module:

- `mise.mac.toml`: Homebrew formulae and casks.
- `mise.devbox.toml`: an Ubuntu 24.04 box reached only over Tailscale. It gets
  apt packages, Tailscale, a host firewall, and a `~/.dotfiles` clone kept on `main`.

Both set zsh as the login shell and install the tools in
`~/.config/mise/config.toml`. Nothing is ever uninstalled.

### Mac

```bash
git clone --recursive https://github.com/brendanator/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
```

`setup.sh` installs mise, saves the module (`mac` on macOS, `devbox` on Linux)
in the gitignored `.miserc.local.toml`, and runs `mise bootstrap`. After that:

```bash
cd ~/.dotfiles
mise bootstrap plan      # packages, files, services, firewall it would change
mise bootstrap --dry-run # everything, including links, shell and tools
mise bootstrap           # apply
mise bootstrap status
```

### Devbox

Devboxes are bootstrapped from the Mac over ssh, and accept ssh only from the
tailnet. For a new Ubuntu 24.04 box with a sudo user:

1. **Join the tailnet** (once). Over the public address, install Tailscale and
   log in:
   ```bash
   ssh <user>@<public-ip>
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up   # open the printed URL to approve the box
   ```
   From now on, use its MagicDNS name, `<box>.<tailnet>.ts.net`, also in
   `~/.ssh/config`.
2. **Lock it down**, so the internet can't reach it at all:
   ```bash
   mise run devbox:lockdown <hetzner-server> --context <hcloud-context> --dry-run
   mise run devbox:lockdown <hetzner-server> --context <hcloud-context>
   ```
   This creates the Hetzner firewall `tailnet-only` in that project if it is
   missing: no rules, applied to servers labelled `tailnet-only=true`. Then it
   labels the server. It refuses if the server isn't a peer on your tailnet.
   Running it again changes nothing.
3. **Add it to the inventory** in the Mac's gitignored `~/.dotfiles/mise.local.toml`.
   Start from `mise.local.toml.example`:
   ```toml
   [bootstrap.remote.hosts.<box>]
   host = "<box>.<tailnet>.ts.net"
   user = "<user>"
   tags = ["devbox"]
   ```
4. **Bootstrap it.** The first run replaces the box's own `~/.bashrc` and other
   default dotfiles, which is what `--force-dotfiles` allows:
   ```bash
   cd ~/.dotfiles
   mise bootstrap remote <box> --dry-run
   mise bootstrap remote <box> --force-dotfiles
   ```

The box's host firewall denies everything incoming except ssh from the tailnet
and Tailscale's WireGuard port. It is a second layer: the Hetzner firewall is
what also covers ports Docker publishes, which skip the host's rules. mise
refuses to apply it over an ssh session that the rules wouldn't allow, so
bootstrap devboxes over their tailnet names.

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
dotfiles sync-remotes  # push, then mise bootstrap remote --all
```

`sync-remotes` bootstraps every box in `mise.local.toml`. Each box first
fast-forwards its `~/.dotfiles` to `main`. Arguments go to
`mise bootstrap remote` instead of `--all`, e.g.
`dotfiles sync-remotes <box> --dry-run` (a dry run doesn't push).
A box whose `~/.dotfiles` has local changes fails without changing anything:
run `dotfiles push` there first.
