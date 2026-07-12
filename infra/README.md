# W VPN infrastructure

Each launch region runs at least two independent WireGuard gateways behind DNS
health steering. The control plane and billing database must be in a separate
network and provider account from gateways. Gateway disks contain no customer
traffic logs. Images should be rebuilt rather than modified in place.

Production requires a private authenticated gateway agent. The API allocates a
peer address and sends only the device public key, address, and expiry to that
agent. `gateway/peer.sh` is the final local operation; it is not a public API.

Required launch nodes:

- `nl-ams-1`, `nl-ams-2`
- `de-fra-1`, `de-fra-2`
- `us-nyc-1`, `us-nyc-2`
- `sg-sin-1`, `sg-sin-2`

## Selected launch provider

DigitalOcean is the launch provider because a single account and API covers the
exact required regions: `ams3`, `fra1`, `nyc3`, and `sgp1`. Start with one
Ubuntu LTS Droplet per region and add the second node after end-to-end load and
failover tests. Enable cloud firewalls so only UDP 51820 is public; SSH is
restricted to the operator's fixed addresses, and the control-plane agent uses
a private authenticated channel.

The service budget assumes normal paid DigitalOcean pricing. The GitHub Student
credit ending on 31 July 2026 may fund temporary validation only and is not a
production dependency. Azure for Students can be used for staging or CI, but
mixing four production gateways across promotional accounts would complicate
operations and account recovery.

Do not source production gateways from anonymous marketplace/forum offers,
"servers for reviews", abuse-resistant hosts, or resellers without a public
legal entity and abuse process. A VPN publisher needs stable IP ownership,
security response, invoices, and predictable account recovery.

Start with 1–2 Gbps VPS networking, measure sustained encrypted throughput, and
scale before average peak load reaches 65%. Do not advertise server counts or
speed claims until measured from independent networks.
