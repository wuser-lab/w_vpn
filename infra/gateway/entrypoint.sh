#!/bin/sh
set -eu

: "${WG_PRIVATE_KEY:?WG_PRIVATE_KEY is required}"
: "${WG_ADDRESS:=10.64.0.1/24}"
: "${WG_PORT:=51820}"
: "${EGRESS_INTERFACE:=eth0}"

umask 077
mkdir -p /etc/wireguard
printf '%s\n' "$WG_PRIVATE_KEY" > /etc/wireguard/private.key

ip link add dev wg0 type wireguard
ip address add "$WG_ADDRESS" dev wg0
wg set wg0 private-key /etc/wireguard/private.key listen-port "$WG_PORT"
ip link set up dev wg0

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o "$EGRESS_INTERFACE" -j MASQUERADE

unbound -d -c /etc/unbound/unbound.conf &
wait "$!"

