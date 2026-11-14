output "id" {
  description = "Resource ID of Azure Firewall"
  value       = azurerm_firewall.afw.id
}

output "name" {
  description = "Name of Azure Firewall"
  value       = azurerm_firewall.afw.name
}

output "private_ip_address" {
  description = "Private IP address of Azure Firewall (used for UDR next-hop)"
  value       = azurerm_firewall.afw.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of Azure Firewall"
  value       = azurerm_public_ip.pip.ip_address
}

output "firewall_policy_id" {
  description = "Resource ID of the Azure Firewall Policy"
  value       = azurerm_firewall_policy.policy.id
}

