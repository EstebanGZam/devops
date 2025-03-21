output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.nic.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.subnet.id
}
