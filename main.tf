#BOXEN TEMPLATE

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.5.1"
    }
  }
}

variable "do_token" {}
variable "do_ssh_fingerprint" {}
variable "do_pvt_key" {}

provider "digitalocean" {
  token = var.do_token
}

#data "digitalocean_ssh_key" "key" {
#  name = var.do_ssh_fingerprint
#}

resource "digitalocean_ssh_key" "ssh" {
    name = "pie"
    public_key = "${file("~/.ssh/digital_ocean_key.pub")}"
}


# Create a new Web Droplet running ubuntu in the FRA1 region
resource "digitalocean_droplet" "server" {
    image  = "ubuntu-20-04-x64"
    name   = "echo"
    region = "fra1"
    size   = "s-1vcpu-1gb"
    ssh_keys =[
      digitalocean_ssh_key.ssh.id
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
      ]
  }
}

resource "digitalocean_firewall" "personal" {
  name = "only-22"

  droplet_ids = [digitalocean_droplet.server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_address   = ["0.0.0.0/0"]
  }
}



# gimmie ip
output "digitalocean_droplet_ip" {
  value = digitalocean_droplet.server.ipv4_address
}

output "digitalocean_droplet_name" {
  value = digitalocean_droplet.server.name
}