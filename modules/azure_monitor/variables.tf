variable "action_group_name" {
  description = "Name of the Monitor Action Group"
  type        = string
}

variable "action_group_short_name" {
  description = "Short name (up to 12 chars) of the Monitor Action Group"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "firewall_id" {
  description = "Resource ID of Azure Firewall to monitor"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log Analytics Workspace"
  type        = string
  default     = null
}

variable "email_receivers" {
  description = "List of email notification recipients"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "webhook_receivers" {
  description = "List of webhook notification endpoints"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

