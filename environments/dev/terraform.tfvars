environment = "dev"
location    = "eastus"

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "Azure-Landing-Zone"
  Owner       = "DevOps"
}

# Hub Network Address Space
hub_address_space          = ["10.100.0.0/16"]
firewall_subnet_cidr       = "10.100.1.0/26"
bastion_subnet_cidr        = "10.100.2.0/26"
gateway_subnet_cidr        = "10.100.255.0/27"
hub_management_subnet_cidr = "10.100.10.0/24"

firewall_sku_tier = "Standard"
firewall_zones    = []

# Spoke 1 - Workloads Network
spoke1_address_space = ["10.101.0.0/16"]
spoke1_subnets = {
  "snet-web" = {
    address_prefixes  = ["10.101.1.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  }
  "snet-app" = {
    address_prefixes  = ["10.101.2.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  }
}

# Spoke 2 - Data Platform Network
spoke2_address_space = ["10.102.0.0/16"]
spoke2_subnets = {
  "snet-db" = {
    address_prefixes  = ["10.102.1.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  }
  "snet-private-endpoints" = {
    address_prefixes  = ["10.102.2.0/24"]
    service_endpoints = []
  }
}

log_retention_days = 30

alert_email_receivers = [
  {
    name          = "DevLead"
    email_address = "devops-alerts@yourdomain.com"
  }
]

rbac_role_assignments = []

