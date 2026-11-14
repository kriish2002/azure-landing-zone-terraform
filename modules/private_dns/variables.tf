variable "resource_group_name" {
  description = "Resource Group where Private DNS Zones will reside"
  type        = string
}

variable "dns_zone_names" {
  description = "List of Private DNS Zone names (e.g. privatelink.blob.core.windows.net)"
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.database.windows.net"
  ]
}

variable "vnet_links" {
  description = "List of VNets to link to the DNS Zones"
  type = list(object({
    name    = string
    vnet_id = string
  }))
  default = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
