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
variable "do_pvt_key" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "key" {
  name = var.do_ssh_fingerprint
}

# Create a new Web Droplet running ubuntu in the FRA1 region
resource "digitalocean_droplet" "server" {
    image  = "ubuntu-20-04-x64"
    name   = "echo"
    region = "fra1"
    size   = "s-1vcpu-1gb"
    ssh_keys =[
      data.digitalocean_ssh_key.key.id
    ]
    connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = file(var.do_pvt_key)
      timeout = "2m"
    }
    provisioner "remote-exec" {
      inline = [
        "export PATH=$PATH:/usr/bin",
        # install nginx
        "export EMAIL=izmennik01@gmail.com",
        "git clone https://github.com/izmennik01/scripts.git",
        "./scripts/bootstrap.sh",
        #"./scripts/home-sync.sh",
      ]
  }
}

# gimmie ip
output "digitalocean_droplet_ip" {
  value = digitalocean_droplet.server.ipv4_address
}

output "digitalocean_droplet_name" {
  value = digitalocean_droplet.server.name
}
