output "id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.rt.id
}

output "name" {
  description = "The name of the Route Table"
  value       = azurerm_route_table.rt.name
}

output "subnets" {
  description = "Subnet IDs associated with this Route Table"
  value       = [for a in azurerm_subnet_route_table_association.assoc : a.subnet_id]
}

