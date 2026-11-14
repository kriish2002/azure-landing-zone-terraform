output "vnet_id" {
  description = "The ID of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "The name of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke.name
}

output "address_space" {
  description = "The address space of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes }
}

