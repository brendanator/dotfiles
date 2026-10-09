# shellcheck shell=bash
# Shared by the devbox:* tasks (mise-tasks/devbox/). Source it; it defines functions only.
#
# A devbox has one name everywhere: its Hetzner server, its tailnet host and its
# inventory entry in mise.local.toml. The entry's tag `hcloud:<context>` names
# the hcloud context (Hetzner project) the server lives in.

# The tailnet's peers, one per line: host name, MagicDNS name (no trailing dot)
# and online state, tab-separated. Fails without the tailscale CLI.
tailnet_peers() {
  tailscale status --json | jq -r '
    .Peer // {} | .[] | [.HostName, (.DNSName | rtrimstr(".")), (if .Online then "online" else "offline" end)] | @tsv'
}

# The MagicDNS name of peer $1 (matched by host name or the first label of its
# MagicDNS name), or nothing when it isn't a peer.
tailnet_dns_name() {
  tailnet_peers | awk -F'\t' -v n="$1" '$1 == n || index($2, n ".") == 1 { print $2; exit }'
}

# The inventory, one host per line: name, ssh host, user and hcloud context,
# tab-separated, with "-" for a missing user or context. Reads $1 (mise.local.toml).
inventory() {
  [ -f "$1" ] || return 0
  uv run --quiet --no-project --python '>=3.11' python -I - "$1" <<'PY'
import sys, tomllib
with open(sys.argv[1], "rb") as f:
    hosts = tomllib.load(f).get("bootstrap", {}).get("remote", {}).get("hosts", {})
for name, h in hosts.items():
    context = next((t.split(":", 1)[1] for t in h.get("tags", []) if t.startswith("hcloud:")), "-")
    print("\t".join([name, h.get("host", name), h.get("user") or "-", context]))
PY
}
