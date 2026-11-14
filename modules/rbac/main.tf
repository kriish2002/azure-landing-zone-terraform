resource "azurerm_role_assignment" "assignments" {
  for_each             = { for item in var.role_assignments : "${item.principal_id}-${item.role_definition_name}-${item.scope}" => item }
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

