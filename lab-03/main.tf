
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

locals {
  project_name = "unixway"
  network_zone = "unuxway.com"
}

resource "libvirt_network" "network" {
  name = local.project_name

  autostart = true
  mode      = "nat"
  domain    = local.network_zone
  addresses = ["10.0.8.0/24"]

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

module "node1" {
  source = "./domain"

  domain_name   = "${local.project_name}-node1"
  domain_memory = "2048"
  domain_vcpu   = "2"

  pool_name = libvirt_pool.pool.name

  network_name    = libvirt_network.network.name
  network_zone    = local.network_zone
  network_address = "10.0.8.11"
  network_bits    = "24"
  network_gateway = "10.0.8.1"

  ssh_public_key_path = "/root/.ssh/id_rsa.pub"
}

module "node2" {
  source = "./domain"

  domain_name   = "${local.project_name}-node2"
  domain_memory = "2048"
  domain_vcpu   = "2"

  pool_name = libvirt_pool.pool.name

  network_name    = libvirt_network.network.name
  network_zone    = local.network_zone
  network_address = "10.0.8.12"
  network_bits    = "24"
  network_gateway = "10.0.8.1"

  ssh_public_key_path = "/root/.ssh/id_rsa.pub"
}

