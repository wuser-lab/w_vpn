locals {
  gateways = {
    nl-ams-1 = { region = "ams3", address = "10.64.10.1/24" }
    de-fra-1 = { region = "fra1", address = "10.64.20.1/24" }
    us-nyc-1 = { region = "nyc3", address = "10.64.30.1/24" }
    sg-sin-1 = { region = "sgp1", address = "10.64.40.1/24" }
  }
}

resource "digitalocean_project" "wvpn" {
  name        = var.project_name
  description = "W VPN production gateway pool"
  purpose     = "Service or API"
  environment = "Production"
}

resource "digitalocean_droplet" "gateway" {
  for_each = local.gateways

  name       = each.key
  region     = each.value.region
  size       = var.droplet_size
  image      = "ubuntu-24-04-x64"
  monitoring = true
  ipv6       = true
  ssh_keys   = [var.ssh_fingerprint]
  tags       = ["wvpn", "gateway", each.value.region]
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    gateway_name    = each.key
    wireguard_cidr  = each.value.address
  })
}

resource "digitalocean_project_resources" "gateways" {
  project   = digitalocean_project.wvpn.id
  resources = [for gateway in digitalocean_droplet.gateway : gateway.urn]
}

resource "digitalocean_firewall" "gateway" {
  name        = "wvpn-gateways"
  droplet_ids = [for gateway in digitalocean_droplet.gateway : gateway.id]

  inbound_rule {
    protocol         = "udp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.operator_cidr]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

