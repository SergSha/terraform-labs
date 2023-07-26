variable "domain_name" {
  type        = string
  description = "Domain name"
}

variable "domain_memory" {
  type        = string
  description = "Memory RAM used by the domain in megabytes"
}

variable "domain_vcpu" {
  type        = string
  description = "vCPU used by the domain"
}

variable "pool_name" {
  type        = string
  description = "Name of the pool domain is using for data provisioning"
}

variable "network_name" {
  type        = string
  description = "Name of the network domain added to"
}

variable "network_zone" {
  type        = string
  description = "Domain DNS Zone"
}

variable "network_address" {
  type        = string
  description = "IP address domain is assigned to"
}

variable "network_bits" {
  type        = string
  description = "Network mask, for example 24 for /24 networks"
}

variable "network_gateway" {
  type        = string
  description = "Gateway of the network"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key to use"
}

variable "source_image" {
  type        = string
  default     = "https://cloud.debian.org/images/cloud/cid/daily/latest/debian-cid-genericcloud-amd64-daily.qcow2"
  description = "Path to source image to use for the images"
}

