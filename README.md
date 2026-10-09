# dotfiles

Personal config, linked into `$HOME` by [mise's dotfiles](https://mise.jdx.dev/dotfiles.html).
Each top-level directory is a group in `mise.toml`; its tree mirrors `$HOME`, and
mise symlinks each file git tracks in it into place.

## New machine

`mise bootstrap` sets a machine up from this repo and keeps it that way. What it
does beyond linking configs comes from the machine's module:

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
in the gitignored `.miserc.local.toml`, and runs `mise bootstrap`. `dotfiles pull`
keeps it current from then on.

### Devboxes

Devboxes are set up and kept up from the Mac, over ssh. There can be any number
of them, in any Hetzner projects. Each one has a single name, used for its
Hetzner server, its tailnet host and its entry in the inventory: the Mac's
gitignored `~/.dotfiles/mise.local.toml` (see `mise.local.toml.example`).

To add a new Ubuntu 24.04 server with a sudo user:

1. **Join it to the tailnet.** This is the one manual step. Over the server's public address:
   ```bash
   ssh <user>@<public-ip>
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up   # open the printed URL to approve the box
   ```
2. **Add it**, from the Mac:
   ```bash
   cd ~/.dotfiles
   mise run devbox:add <box> --context <hcloud-context> [--user <user>] --dry-run
   mise run devbox:add <box> --context <hcloud-context> [--user <user>]
   ```
   This:
   - checks the box is a peer on your tailnet;
   - locks it down (`devbox:lockdown`, below);
   - adds it to the inventory;
   - bootstraps it over its MagicDNS name. The first run replaces the box's own
     `~/.bashrc` and other default dotfiles.

   `--user` defaults to your user on the Mac. Every step is idempotent, so running it again
   only bootstraps the box again.

After that, these cover every box:

```bash
dotfiles sync-remotes    # push, then bootstrap every box in the inventory
mise run devbox:status   # check them all, read-only
```

`devbox:status` prints one line per box:

- **TAILNET:** whether it's a peer, and online.
- **HETZNER:** whether it's labelled `tailnet-only=true` in the project its
  `hcloud:<context>` tag names.
- **BOOTSTRAP:** whether `mise bootstrap remote <box> --dry-run` finds it
  converged. Otherwise it lists what would change.

It exits 1 if any box needs attention. `--quick` skips the dry runs.

#### Lockdown

`mise run devbox:lockdown <server> --context <hcloud-context> [--dry-run]` closes a
server to the internet. It creates the Hetzner firewall `tailnet-only` in that
project if it's missing: no rules, applied to every server labelled
`tailnet-only=true`. Then it labels the server. Tailscale still works, because it
dials out.

Because the firewall covers every labelled server in the project, the task first lists
them all. It refuses unless each one, and the new server, is a peer on your
tailnet. Running it again changes nothing.

#### Host firewall

A box's host firewall guards only ssh. Port 22 accepts the tailnet
(`100.64.0.0/10`, `fd7a:115c:a1e0::/48`) and refuses everyone else, and every
other port is left open. The Hetzner firewall is the main wall, and the only one
that also covers ports Docker publishes, which skip the host's rules. Bootstrap
devboxes over their tailnet names. A run over a public address finishes, but new
ssh sessions to that address are refused afterwards.

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
`dotfiles sync-remotes <box> --dry-run` or `--tag devbox` (a dry run doesn't push).
A box whose `~/.dotfiles` has local changes fails without changing anything:
run `dotfiles push` there first.
