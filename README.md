# W VPN

Minimal, privacy-first VPN service for iPhone, macOS, and Android.

> Bundle identifiers, domains, and legal entity details must be finalized before release.

## Product scope

- WireGuard tunnel on iOS/macOS through Apple Network Extension
- WireGuard tunnel on Android through `VpnService`
- Account, device, subscription, and server-selection API
- Short-lived configuration delivery; private keys are generated on-device
- Minimal black/graphite/white interface with accessible contrast
- App Store and Google Play release metadata and compliance checklist
- Reproducible VPN gateway provisioning and monitoring
- Launch regions: Netherlands, Germany, United States, and Singapore
- Paid subscription through StoreKit and Google Play Billing, with optional web billing
- W Flow: adaptive routing, visible protection proof, and guarded route recovery

## Repository layout

```text
apps/
  apple/       SwiftUI iOS + macOS client and packet-tunnel extension
  android/     Kotlin + Jetpack Compose client and VPN service
services/
  api/         Control-plane API
infra/         Gateway and observability deployment
design/        Shared design tokens and UI specification
docs/          Architecture, privacy, security, and store-release material
```

## Non-negotiable security rules

1. Never log browsing traffic, DNS queries, destination IPs, or tunnel payloads.
2. Generate WireGuard private keys locally and store them in Keychain/Keystore.
3. Return credentials only over TLS; rotate and revoke device peers independently.
4. Keep billing identity separate from operational VPN telemetry.
5. Collect only coarse health metrics that cannot reconstruct user activity.
6. Pin dependency versions and review licenses before shipping binaries.

## Local prerequisites

- Current stable Xcode with iOS/macOS SDKs and an Apple Developer team
- Android Studio with a current JDK and Android SDK
- Docker/Compose for the API and local database
- Go toolchain for the control plane

The current machine has Apple Command Line Tools only, Java 8, and no Android
SDK, Docker, Node, or Go. Native builds therefore cannot yet be verified here.

## Release blockers owned by the publisher

- Final icon, domain, support email, and legal entity
- Apple Developer and Google Play Console access
- Network Extension entitlement approval and signing profiles
- Subscription products, prices, tax/banking setup, and store agreements
- Privacy policy, terms, regional availability, and support process
- Production cloud/VPS account and DNS access
