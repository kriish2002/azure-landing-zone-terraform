environment = "prod"
location    = "eastus"

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "Azure-Landing-Zone"
  Owner       = "CloudOps"
  Compliance  = "PCI-DSS-Baseline"
}

# Hub Network Address Space
hub_address_space          = ["10.0.0.0/16"]
firewall_subnet_cidr       = "10.0.1.0/26"
bastion_subnet_cidr        = "10.0.2.0/26"
gateway_subnet_cidr        = "10.0.255.0/27"
hub_management_subnet_cidr = "10.0.10.0/24"

firewall_sku_tier = "Standard"
firewall_zones    = ["1", "2", "3"]

# Spoke 1 - Workloads Network
spoke1_address_space = ["10.1.0.0/16"]
spoke1_subnets = {
  "snet-web" = {
    address_prefixes  = ["10.1.1.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  }
  "snet-app" = {
    address_prefixes  = ["10.1.2.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  }
}

# Spoke 2 - Data Platform Network
spoke2_address_space = ["10.2.0.0/16"]
spoke2_subnets = {
  "snet-db" = {
    address_prefixes  = ["10.2.1.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  }
  "snet-private-endpoints" = {
    address_prefixes  = ["10.2.2.0/24"]
    service_endpoints = []
  }
}

log_retention_days = 90

alert_email_receivers = [
  {
    name          = "CloudSecOps"
    email_address = "secops-alerts@yourdomain.com"
  },
  {
    name          = "CloudOpsLead"
    email_address = "cloudops@yourdomain.com"
  }
]

# Set specific Azure AD principal IDs for Landing Zone management
rbac_role_assignments = []

