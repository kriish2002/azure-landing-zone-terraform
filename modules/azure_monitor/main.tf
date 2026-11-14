resource "azurerm_monitor_action_group" "ag" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.webhook_receivers
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = true
    }
  }
}

# Azure Firewall Health State Alert
resource "azurerm_monitor_metric_alert" "fw_health" {
  count               = var.firewall_id != null ? 1 : 0
  name                = "alert-firewall-health-status"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Triggers when Azure Firewall Health State is degraded"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallHealth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}

# Azure Firewall SNAT Port Utilization Alert
resource "azurerm_monitor_metric_alert" "fw_snat_utilization" {
  count               = var.firewall_id != null ? 1 : 0
  name                = "alert-firewall-snat-port-utilization"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Triggers when Azure Firewall SNAT Port Utilization exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "SNATPortUtilization"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}

# Scheduled Query Rule (Log Analytics alert on Firewall Blocked Traffic)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "fw_blocked_traffic" {
  count                = var.log_analytics_workspace_id != null ? 1 : 0
  name                 = "alert-firewall-denied-traffic-spike"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [var.log_analytics_workspace_id]
  description          = "Triggers when there is an unusual spike in denied connections through Azure Firewall"
  severity             = 2
  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  tags                 = var.tags

  criteria {
    query                   = <<-QUERY
      AZFWNetworkRule
      | where Action == "Deny"
      | summarize DenyCount = count() by bin(TimeGenerated, 5m)
      | where DenyCount > 100
    QUERY
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }
}
