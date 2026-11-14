variable "name" {
  description = "Name of the Azure Bastion host"
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

variable "subnet_id" {
  description = "Resource ID of the AzureBastionSubnet"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the Bastion Public IP"
  type        = string
}

variable "sku" {
  description = "SKU of Bastion (Basic, Standard)"
  type        = string
  default     = "Standard"
}

variable "scale_units" {
  description = "Scale units for Bastion (2-50 for Standard)"
  type        = number
  default     = 2
}

variable "copy_paste_enabled" {
  description = "Enable copy paste feature"
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Enable file copy feature (Standard SKU only)"
  type        = bool
  default     = true
}

variable "tunneling_enabled" {
  description = "Enable native client support / tunneling (Standard SKU only)"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID for diagnostic logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

