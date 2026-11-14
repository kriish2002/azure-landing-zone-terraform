output "id" {
  description = "Resource ID of the Bastion Host"
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "Name of the Bastion Host"
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "FQDN for the Bastion Host"
  value       = azurerm_bastion_host.bastion.dns_name
}

output "public_ip_address" {
  description = "Public IP address of the Bastion Host"
  value       = azurerm_public_ip.pip.ip_address
}

