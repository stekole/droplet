#BOXEN TEMPLATE

variable "digitalocean_token" {}
variable "digitalocean_ssh_fingerprint" {}



provider "digitalocean" {
  token = "${var.digitalocean_token}"   // referencing the token you exported earlier using var
}



# Create a new Web Droplet running ubuntu in the FRA1 region
resource "digitalocean_droplet" "server" {
    image  = "ubuntu-16-04-x64"
    name   = "server"
    region = "fra1"
    size   = "1gb"
    ssh_keys =[
      "${var.digitalocean_ssh_fingerprint}"
    ]
}

# gimmie ip
output "digitalocean_droplet_ip" {
  value = "${digitalocean_droplet.server.ipv4_address}"
}

output "digitalocean_droplet_name" {
  value = "${digitalocean_droplet.server.name}"
}
