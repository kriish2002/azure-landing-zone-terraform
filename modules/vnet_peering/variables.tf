variable "hub_vnet_name" {
  description = "The name of the Hub VNet"
  type        = string
}

variable "hub_vnet_id" {
  description = "The ID of the Hub VNet"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource Group where Hub VNet resides"
  type        = string
}

variable "spoke_vnet_name" {
  description = "The name of the Spoke VNet"
  type        = string
}

variable "spoke_vnet_id" {
  description = "The ID of the Spoke VNet"
  type        = string
}

variable "spoke_resource_group_name" {
  description = "Resource Group where Spoke VNet resides"
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Controls if VMs in one VNet can communicate with the other"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs outside the VNet is allowed"
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "Controls if Gateway transit is enabled on Hub side"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Controls if remote gateway is used on Spoke side"
  type        = bool
  default     = false
}

