variable "vnet_name" {
  description = "Name of the Hub Virtual Network"
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

variable "address_space" {
  description = "Address space CIDRs for the Hub VNet (e.g. ['10.0.0.0/16'])"
  type        = list(string)
}

variable "firewall_subnet_cidr" {
  description = "CIDR prefix for AzureFirewallSubnet (e.g. '10.0.1.0/26')"
  type        = string
}

variable "bastion_subnet_cidr" {
  description = "CIDR prefix for AzureBastionSubnet (e.g. '10.0.2.0/26')"
  type        = string
}

variable "gateway_subnet_cidr" {
  description = "CIDR prefix for GatewaySubnet (e.g. '10.0.255.0/27'). Set null to omit."
  type        = string
  default     = null
}

variable "management_subnet_name" {
  description = "Name for shared management subnet"
  type        = string
  default     = "snet-hub-mgmt"
}

variable "management_subnet_cidr" {
  description = "CIDR prefix for shared management subnet (e.g. '10.0.10.0/24'). Set null to omit."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of custom DNS servers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

