output "hub_resource_group_name" {
  description = "The Resource Group name of the Hub"
  value       = module.rg_hub.name
}

output "hub_vnet_id" {
  description = "Resource ID of the Hub VNet"
  value       = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  description = "Name of the Hub VNet"
  value       = module.hub_network.vnet_name
}

output "azure_firewall_private_ip" {
  description = "Azure Firewall private IP for next-hop routing"
  value       = module.azure_firewall.private_ip_address
}

output "azure_firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = module.azure_firewall.public_ip_address
}

output "azure_bastion_dns_name" {
  description = "Azure Bastion DNS hostname for secure management"
  value       = module.azure_bastion.dns_name
}

output "spoke1_vnet_id" {
  description = "Resource ID of Spoke 1 (Workloads) VNet"
  value       = module.spoke1.vnet_id
}

output "spoke2_vnet_id" {
  description = "Resource ID of Spoke 2 (Data Platform) VNet"
  value       = module.spoke2.vnet_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of central Log Analytics Workspace"
  value       = module.log_analytics.id
}

