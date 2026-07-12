variable "digitalocean_token" {
  description = "DigitalOcean API token. Supply via TF_VAR_digitalocean_token; never commit it."
  type        = string
  sensitive   = true
}

variable "ssh_fingerprint" {
  description = "Fingerprint of an SSH key already added to the publisher-owned DigitalOcean account."
  type        = string
}

variable "operator_cidr" {
  description = "Fixed public operator address allowed to use SSH, in CIDR form."
  type        = string
}

variable "droplet_size" {
  description = "Launch size; scale after encrypted throughput testing."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "project_name" {
  type    = string
  default = "W VPN"
}

