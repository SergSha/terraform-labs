
terraform {
  required_providers {
    libvirt = {
      source ="dmacvicar/libvirt"
    }
  }
}

resource "libvirt_volume" "debian_volume" {
  name   = "${var.domain_name}-root"
  pool   = var.pool_name
  source = "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/files/cloud_init.cfg")
  vars = {
    domain_name    = var.domain_name
    network_zone   = var.network_zone
    ssh_public_key = file(var.ssh_public_key_path)
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/files/network_config.cfg")
  vars = {
    network_zone    = var.network_zone
    network_address = var.network_address
    network_bits    = var.network_bits
    network_gateway = var.network_gateway
  }
}

# Install mkisofs
# https://command-not-found.com/mkisofs
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.domain_name}-commoninit"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = var.pool_name
}

resource "libvirt_domain" "domain" {
  name   = var.domain_name
  memory = var.domain_memory
  vcpu   = var.domain_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = var.network_name
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bug.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.debian_volume.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

