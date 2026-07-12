output "gateways" {
  description = "Public gateway addresses. WireGuard remains disabled until keys are installed."
  value = {
    for name, gateway in digitalocean_droplet.gateway : name => {
      ipv4   = gateway.ipv4_address
      ipv6   = gateway.ipv6_address
      region = gateway.region
    }
  }
}

