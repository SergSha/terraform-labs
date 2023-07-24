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
  description = "IP Address"
}

variable "network_bits" {
  type        = string
  description = "Prefix"
}

variable "network_gateway" {
  type        = string
  description = "Network Gateway"
}

variable "ssh_public_key_path" {
  type        = string
  description = "SSH Public Key Path"
}

