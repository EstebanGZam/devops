variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
}

variable "network_interface_name" {
  description = "Name of the network interface"
  type        = string
}

variable "network_security_group_name" {
  description = "Name of the network security group"
  type        = string
}
