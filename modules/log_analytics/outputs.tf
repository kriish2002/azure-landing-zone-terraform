output "id" {
  description = "Log Analytics Workspace resource ID"
  value       = azurerm_log_analytics_workspace.law.id
}

output "name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.law.name
}

output "workspace_id" {
  description = "Log Analytics Workspace GUID (workspace_id)"
  value       = azurerm_log_analytics_workspace.law.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key for Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive   = true
}

