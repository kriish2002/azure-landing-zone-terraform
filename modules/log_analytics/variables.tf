variable "name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "sku" {
  description = "SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Workspace data retention in days (30 to 730)"
  type        = number
  default     = 30
}

variable "solutions" {
  description = "List of OMS solutions to install (e.g. VMInsights, SecurityInsights)"
  type        = list(string)
  default     = ["VMInsights"]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

