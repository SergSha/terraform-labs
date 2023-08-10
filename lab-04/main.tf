
terraform {
  required_providers {
    libvirt = {
      source ="dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Connect to local KVM hypervisor
  #uri = "qemu:///system"
  # Connect to remote KVM hypervisor
  uri = "qemu+ssh://root@192.168.157.16/system"
}

locals {
  project_name = "k8s"

  network_domain = "dominus.org"
  network_mask = "10.22.5.0"
  network_bits = 24
}

resource "libvirt_network" "network" {
  name = local.project_name

  autostart = true
  mode      = "nat"
  domain    = local.network_domain
  addresses = ["${local.network_mask}/${local.network_bits}"]

  dns {
    enabled    = true
    local_only = true
  }
}

resource "libvirt_pool" "pool" {
  name = local.project_name
  type = "dir"
  path = "/QEMU/${local.project_name}"
}

module "masters" {
  count = 3

  source = "./domain"

  domain_name   = "${local.project_name}-master${count.index}"
  network_zone    = local.network_domain
  domain_memory = "2000"
  domain_vcpu   = "2"

  pool_name = libvirt_pool.pool.name

  network_name    = libvirt_network.network.name
  network_address = cidrhost("${local.network_mask}/${local.network_bits}", sum([10, count.index]))
  network_bits    = "local.network_bits"
  network_gateway = "10.22.5.1"

  source_image = "/QEMU/images/debian-sid-genericcloud-amd64-daily.qcow2"

  ssh_public_key_path = "/root/.ssh/id_rsa.pub"
}

module "nodes" {
  count = 6

  source = "./domain"

  domain_name   = "${local.project_name}-node${count.index}"
  network_zone    = local.network_domain
  domain_memory = "2000"
  domain_vcpu   = "2"

  pool_name = libvirt_pool.pool.name

  network_name    = libvirt_network.network.name
  network_address = cidrhost("${local.network_mask}/${local.network_bits}", sum([20, count.index]))
  network_bits    = "local.network_bits"
  network_gateway = "10.22.5.1"

  source_image = "/QEMU/images/debian-sid-genericcloud-amd64-daily.qcow2"

  ssh_public_key_path = "/home/user/.ssh/id_rsa.pub"
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      masters = module.masters
      nodes = module.nodes
    }
  )
  filename = "./inventory.ini"
}
