variable "role_assignments" {
  description = "List of RBAC assignments"
  type = list(object({
    principal_id         = string
    role_definition_name = string
    scope                = string
  }))
  default = []
}

