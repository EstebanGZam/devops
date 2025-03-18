# variables.tf

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for Azure resources."
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created."
  default     = "West Europe"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network."
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet."
}

variable "network_interface_name" {
  type        = string
  description = "The name of the network interface."
}

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine."
}

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_F2"
}

variable "admin_username" {
  type        = string
  description = "The admin username for the virtual machine."
}

variable "admin_password" {
  type        = string
  description = "The admin password for the virtual machine."
  sensitive   = true
}

variable "network_security_group_name" {
  type        = string
  description = "The name of the network security group."
}

variable "public_ip_name" {
  type        = string
  description = "The name of the public IP address."
}