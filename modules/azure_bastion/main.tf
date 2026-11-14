resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.scale_units
  copy_paste_enabled  = var.copy_paste_enabled
  file_copy_enabled   = var.sku == "Standard" ? var.file_copy_enabled : null
  tunneling_enabled   = var.sku == "Standard" ? var.tunneling_enabled : null
  tags                = var.tags

  ip_configuration {
    name                 = "BastionIpConfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "bastion_diag" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

