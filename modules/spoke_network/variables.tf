variable "vnet_name" {
  description = "The name of the Spoke Virtual Network"
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
  description = "Address space CIDRs for the Spoke VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets configuration"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = optional(list(string), [])
    }), null)
  }))
  default = {}
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

