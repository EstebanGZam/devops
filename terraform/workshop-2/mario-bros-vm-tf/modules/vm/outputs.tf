output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
}

