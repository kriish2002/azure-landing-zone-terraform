resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "policy" {
  name                = var.firewall_policy_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_tier
  tags                = var.tags

  dns {
    proxy_enabled = true
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 200

  network_rule_collection {
    name     = "CoreInfrastructureRules"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "Allow-NTP"
      protocols             = ["UDP"]
      source_addresses      = var.allowed_source_cidrs
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "Allow-DNS"
      protocols             = ["UDP", "TCP"]
      source_addresses      = var.allowed_source_cidrs
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "Allow-Inter-Spoke-Internal"
      protocols             = ["TCP", "UDP"]
      source_addresses      = var.allowed_source_cidrs
      destination_addresses = var.allowed_source_cidrs
      destination_ports     = ["443", "80", "8080", "8443", "3306", "5432", "1433"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  name               = "DefaultAppRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 300

  application_rule_collection {
    name     = "WebAndOSUpdates"
    priority = 100
    action   = "Allow"

    rule {
      name             = "Allow-Microsoft-Updates"
      source_addresses = var.allowed_source_cidrs
      destination_fqdns = [
        "*.microsoft.com",
        "*.azure.com",
        "*.windowsupdate.com"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "Allow-Ubuntu-Updates"
      source_addresses = var.allowed_source_cidrs
      destination_fqdns = [
        "*.archive.ubuntu.com",
        "*.security.ubuntu.com"
      ]
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

resource "azurerm_firewall" "afw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  zones               = var.availability_zones
  tags                = var.tags

  ip_configuration {
    name                 = "FirewallIpConfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_firewall.afw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

