output "assignment_ids" {
  description = "List of role assignment IDs"
  value       = [for a in azurerm_role_assignment.assignments : a.id]
}

