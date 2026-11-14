variable "environment" {
  description = "Target deployment environment (e.g. prod, dev)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Common baseline tags"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Azure-Landing-Zone"
    Owner       = "CloudOps"
  }
}

# Hub Network Settings
variable "hub_address_space" {
  description = "Address space CIDRs for the Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "firewall_subnet_cidr" {
  description = "CIDR prefix for AzureFirewallSubnet (min /26)"
  type        = string
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_cidr" {
  description = "CIDR prefix for AzureBastionSubnet (min /26)"
  type        = string
  default     = "10.0.2.0/26"
}

variable "gateway_subnet_cidr" {
  description = "CIDR prefix for GatewaySubnet (min /27)"
  type        = string
  default     = "10.0.255.0/27"
}

variable "hub_management_subnet_cidr" {
  description = "CIDR prefix for Hub Management subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU Tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "firewall_zones" {
  description = "Availability zones for Azure Firewall"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Spoke 1 Settings (Workloads / App Tier)
variable "spoke1_address_space" {
  description = "Address space for Spoke 1 (Workloads)"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke1_subnets" {
  description = "Subnet definitions for Spoke 1"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {
    "snet-web" = {
      address_prefixes  = ["10.1.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-app" = {
      address_prefixes  = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    }
  }
}

# Spoke 2 Settings (Data & Private Endpoints)
variable "spoke2_address_space" {
  description = "Address space for Spoke 2 (Data Platform)"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "spoke2_subnets" {
  description = "Subnet definitions for Spoke 2"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {
    "snet-db" = {
      address_prefixes  = ["10.2.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-private-endpoints" = {
      address_prefixes  = ["10.2.2.0/24"]
      service_endpoints = []
    }
  }
}

# Monitoring & Alerts
variable "log_retention_days" {
  description = "Log Analytics Workspace retention period in days"
  type        = number
  default     = 90
}

variable "alert_email_receivers" {
  description = "Email addresses to receive Azure Monitor alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = [
    {
      name          = "CloudSecOps"
      email_address = "secops-alerts@example.com"
    }
  ]
}

# RBAC
variable "rbac_role_assignments" {
  description = "RBAC role assignments for Landing Zone management"
  type = list(object({
    principal_id         = string
    role_definition_name = string
    scope                = string
  }))
  default = []
}

