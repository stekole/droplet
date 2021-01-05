#BOXEN TEMPLATE

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "1.22.2"
    }
  }
}

variable "do_token" {}
variable "do_ssh_fingerprint" {}


provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "key" {
  name = var.do_ssh_fingerprint
}

# Create a new Web Droplet running ubuntu in the FRA1 region
resource "digitalocean_droplet" "server" {
    image  = "ubuntu-16-04-x64"
    name   = "server"
    region = "fra1"
    size   = "1gb"
    ssh_keys =[
      "${var.do_ssh_fingerprint}"
    ]
}

# gimmie ip
output "digitalocean_droplet_ip" {
  value = "${digitalocean_droplet.server.ipv4_address}"
}

output "digitalocean_droplet_name" {
  value = "${digitalocean_droplet.server.name}"
}
