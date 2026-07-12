#!/bin/sh
set -eu

# Called by a private gateway agent after the control plane authenticates and
# authorizes a tunnel. Never expose this script or the WireGuard control socket
# to the public internet.
case "${1:-}" in
  add)
    : "${2:?public key required}" "${3:?allowed address required}"
    wg set wg0 peer "$2" allowed-ips "$3"
    ;;
  remove)
    : "${2:?public key required}"
    wg set wg0 peer "$2" remove
    ;;
  *) echo "usage: peer.sh add PUBLIC_KEY ADDRESS | remove PUBLIC_KEY" >&2; exit 2 ;;
esac

