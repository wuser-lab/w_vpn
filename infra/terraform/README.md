# DigitalOcean deployment

This Terraform configuration creates one fail-closed W VPN gateway in each
launch region: Amsterdam, Frankfurt, New York, and Singapore. Cloud-init does
not start WireGuard with a placeholder key. Keys are installed separately over
the restricted operator channel, so Terraform state never contains gateway
private keys.

## Before applying

1. Create or use a publisher-owned DigitalOcean account; never buy an account.
2. Treat promotional credits as temporary test funding, not as part of the
   production cost model. The GitHub Student offer is ending on 31 July 2026.
3. Add an SSH public key to DigitalOcean.
4. Create a short-lived scoped API token for deployment.
5. Copy `terraform.tfvars.example` to an ignored `terraform.tfvars` and replace
   the fingerprint and operator IP.
6. Export the token only in the current shell:
   `export TF_VAR_digitalocean_token='...'`.

Run `terraform init`, `terraform plan`, review the exact monthly estimate in the
DigitalOcean console, and only then run `terraform apply`. Applying creates
billable cloud resources and must be explicitly approved by the publisher.
