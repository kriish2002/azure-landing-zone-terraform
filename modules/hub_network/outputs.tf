output "vnet_id" {
  description = "The ID of the Hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "The name of the Hub VNet"
  value       = azurerm_virtual_network.hub.name
}

output "address_space" {
  description = "The address space of the Hub VNet"
  value       = azurerm_virtual_network.hub.address_space
}

output "firewall_subnet_id" {
  description = "The ID of the AzureFirewallSubnet"
  value       = azurerm_subnet.firewall.id
}

output "bastion_subnet_id" {
  description = "The ID of the AzureBastionSubnet"
  value       = azurerm_subnet.bastion.id
}

output "gateway_subnet_id" {
  description = "The ID of the GatewaySubnet"
  value       = length(azurerm_subnet.gateway) > 0 ? azurerm_subnet.gateway[0].id : null
}

output "management_subnet_id" {
  description = "The ID of the Management Subnet"
  value       = length(azurerm_subnet.management) > 0 ? azurerm_subnet.management[0].id : null
}

