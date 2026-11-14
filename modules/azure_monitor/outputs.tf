output "action_group_id" {
  description = "Resource ID of the Action Group"
  value       = azurerm_monitor_action_group.ag.id
}

output "fw_health_alert_id" {
  description = "Resource ID of Firewall health alert"
  value       = length(azurerm_monitor_metric_alert.fw_health) > 0 ? azurerm_monitor_metric_alert.fw_health[0].id : null
}

