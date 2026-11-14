resource "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.dns_zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each = {
    for pair in setproduct(var.dns_zone_names, var.vnet_links) :
    "${pair[0]}-${pair[1].name}" => {
      zone_name = pair[0]
      vnet_name = pair[1].name
      vnet_id   = pair[1].vnet_id
    }
  }

  name                  = "link-${each.value.vnet_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.value.zone_name].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
