variable "name" {
  description = "Name of the Azure Firewall"
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
  description = "Resource ID of the AzureFirewallSubnet"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the Azure Firewall Public IP"
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the Azure Firewall Policy"
  type        = string
}

variable "sku_tier" {
  description = "SKU tier of the Firewall (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "availability_zones" {
  description = "Availability zones to deploy Firewall into (e.g. ['1', '2', '3'])"
  type        = list(string)
  default     = []
}

variable "allowed_source_cidrs" {
  description = "CIDR ranges allowed for default firewall rules"
  type        = list(string)
  default     = ["10.0.0.0/8"]
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

