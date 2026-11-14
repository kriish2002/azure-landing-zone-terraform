output "id" {
  description = "The ID of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "name" {
  description = "The name of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "The private IP address of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
}
