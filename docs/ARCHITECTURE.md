# Architecture

## Components

```text
Apple client ─┐
              ├── HTTPS control plane ── PostgreSQL
Android client┘          │
                         ├── subscription entitlement verification
                         └── encrypted peer provisioning

Apple Network Extension ─┐
Android VpnService ──────┴── WireGuard gateway pool ── Internet
```

The control plane authenticates users, registers public keys, chooses a healthy
gateway, and issues a WireGuard peer configuration. Tunnel traffic never passes
through the API. Gateways know a peer public key and assigned tunnel address,
but do not receive billing identity.

## Client state machine

`signedOut -> ready -> permissionRequired -> connecting -> connected`

Failures transition to `recoverableError` with a human-readable action. Revoked
or expired entitlement transitions to `subscriptionRequired`. A kill switch is
off by default for the first release and must be explicitly enabled by the user.

## API surface (v1)

- `POST /v1/auth/apple` and `POST /v1/auth/google`
- `GET /v1/regions`
- `POST /v1/devices`
- `DELETE /v1/devices/{id}`
- `POST /v1/tunnels`
- `DELETE /v1/tunnels/{id}`
- `POST /v1/billing/apple/notifications`
- `POST /v1/billing/google/notifications`
- `GET /v1/me/entitlement`
- `GET /healthz` and `GET /readyz`

## Data minimization

Store account ID, provider subject, entitlement, device public key, assigned
address, selected region, and coarse service timestamps. Do not store browsing
history, DNS content, destination addresses, or per-user traffic logs. Aggregate
gateway capacity metrics must not contain stable user identifiers.

