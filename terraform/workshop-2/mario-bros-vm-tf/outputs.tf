output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.vm.vm_id
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = module.vm.vm_private_ip
}