variable "name" {
  description = "Name of the Route Table"
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

variable "disable_bgp_route_propagation" {
  description = "Whether to disable BGP route propagation"
  type        = bool
  default     = false
}

variable "routes" {
  description = "List of user-defined routes"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

variable "subnet_ids" {
  description = "List of Subnet IDs to associate with this Route Table"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

