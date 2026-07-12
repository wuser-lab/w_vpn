# W VPN product direction

## Positioning

**The VPN that proves it is working and quietly chooses the best route for what
you are doing.**

W VPN does not compete on a giant country counter or a bundle of unrelated
security products. It competes on confidence, connection quality, and a calm
interface. Four carefully operated regions are more credible at launch than a
map filled with rented, poorly monitored endpoints.

## Signature system: W Flow

W Flow combines three features into one user experience.

### W Route

Instead of selecting a country first, the user selects an intent:

- **Everyday** — lowest latency and battery impact
- **Private** — optional two-hop route through different jurisdictions
- **Travel** — aggressively reconnects across hotel, airport, Wi-Fi, and mobile
  network changes
- **Manual** — explicit Netherlands, Germany, United States, or Singapore exit

The device performs tiny encrypted probes to candidate gateways and ranks them
using latency, packet loss, recent failures, and gateway capacity. Browsing
history and destination domains are never inputs. The chosen route is explained
in one sentence: “Germany — 24 ms, stable, 38% load.”

### W Proof

After connecting, the central control transforms into a live proof card:

- tunnel handshake is current;
- public IP changed;
- DNS is using W VPN resolvers;
- IPv6 is protected or explicitly unavailable;
- connection duration and quality are visible.

The proof check runs from the client and reports a simple **Protected** state,
not a theatrical animation. A shareable diagnostic report contains no account,
IP address, browsing, DNS, or location history.

### W Shift

When the current route degrades, W VPN prepares a healthier peer and switches
with a kill-switch guard. The UI records a local-only event such as “Moved from
Amsterdam to Frankfurt — packet loss recovered.” Raw network history leaves the
device only if the user explicitly sends diagnostics.

## Why users download it

1. They immediately understand whether the VPN truly protects them.
2. They do not need to know which server or protocol is best.
3. Network changes during travel recover automatically.
4. The app has no ads, fake urgency, map clutter, or surprise upsells.
5. Privacy promises are expressed as visible technical evidence.

## Interface

The home screen contains one large monochrome W control, the current W Flow
mode, and the W Proof card. Country selection lives in a bottom sheet. Advanced
options are hidden until requested. White indicates protected, graphite means
idle, and amber means attention is needed. Red is reserved for real leakage or
connection failure.

## Credibility roadmap

- Publish client source code before public launch.
- Commission an independent client, API, and gateway audit.
- Publish reproducible gateway images and a plain-language data inventory.
- Add a public status page with regional latency and incident history.
- Never claim “anonymous” or “zero logs” without auditable controls supporting it.

## Launch message

**W VPN — protection you can see.**

Supporting line: **One tap. The right route. Visible proof.**

