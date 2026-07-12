# Billing model

## Product

One entitlement, `premium`, unlocks every gateway region on all supported
platforms. A user account links Apple, Google Play, and optional web purchases so
the customer does not pay twice when switching devices.

## Initial products

| Product ID | Period | Intro offer | Suggested launch price |
|---|---:|---:|---:|
| `wvpn.monthly` | 1 month | none | EUR 4.99 |
| `wvpn.yearly` | 1 year | 7 days | EUR 39.99 |

Storefronts localize currency and tax. Final prices are configured in App Store
Connect and Play Console rather than hard-coded in the clients.

## Payment routes

- iPhone/macOS: StoreKit 2 auto-renewable subscription. Apple Pay is not the
  default purchase mechanism for digital functionality inside the app.
- Android: Google Play Billing auto-renewing subscription.
- Website, later: Stripe Checkout can sell the same account entitlement where
  store rules permit it. The website route must not be promoted inside a
  storefront app unless the applicable storefront and region rules allow it.

## Entitlement verification

Clients never decide premium access solely from a local receipt. The backend
verifies signed Apple transactions and Google Play purchases, processes server
notifications, and returns a normalized entitlement:

```json
{
  "plan": "premium",
  "status": "active",
  "source": "apple",
  "expiresAt": "2027-07-12T12:00:00Z"
}
```

The service allows a short grace period during store outages and revokes access
after expiry, refund, chargeback, or billing retry failure according to the
store-reported state.

## Business assumptions

- No advertising and no sale of user data.
- Monthly and annual plans only at launch.
- One account may register up to five active devices.
- Subscription grants access to Netherlands, Germany, United States, and
  Singapore gateways.
- Prices are placeholders until infrastructure cost and VAT margin are modeled.

