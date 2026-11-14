output "zone_ids" {
  description = "Map of DNS zone names to their resource IDs"
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}

output "zone_names" {
  description = "List of created Private DNS Zone names"
  value       = [for z in azurerm_private_dns_zone.zones : z.name]
}
