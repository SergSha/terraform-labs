
terraform {
  required_providers {
    libvirt = {
      source ="dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "network" {
  name = "network3"

  autostart = true
  mode      = "nat"
  domain    = "unixway.org"
  addresses = ["10.0.7.0/24"]

  dns {
    enabled    = true
    local_only = true
  }
}

resource "libvirt_pool" "pool" {
  name = "pool3"
  type = "dir"
  path = "/QEMU/pool3"
}

resource "libvirt_volume" "server_root" {
  name   = "server_root"
  pool   = libvirt_pool.pool.name
  source = "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/files/cloud_init.cfg")
  vars = {
    domain_name = "server-test1"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/files/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "server_cloudinit"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_domain" "server" {
  name   = "server-test1"
  memory = 1024
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = libvirt_network.network.name
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
    volume_id = libvirt_volume.server_root.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

