# ---------------------------------------------------------------------------------------------------------------------
# 1. RESOURCE GROUPS (CAF compliant naming)
# ---------------------------------------------------------------------------------------------------------------------
module "rg_hub" {
  source   = "../../modules/resource_group"
  name     = "rg-hub-${var.environment}-${var.location}"
  location = var.location
  tags     = var.tags
}

module "rg_spoke1" {
  source   = "../../modules/resource_group"
  name     = "rg-spoke-workloads-${var.environment}-${var.location}"
  location = var.location
  tags     = var.tags
}

module "rg_spoke2" {
  source   = "../../modules/resource_group"
  name     = "rg-spoke-data-${var.environment}-${var.location}"
  location = var.location
  tags     = var.tags
}

module "rg_ops" {
  source   = "../../modules/resource_group"
  name     = "rg-operations-${var.environment}-${var.location}"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. LOG ANALYTICS WORKSPACE & PLATFORM MONITORING
# ---------------------------------------------------------------------------------------------------------------------
module "log_analytics" {
  source              = "../../modules/log_analytics"
  name                = "log-alz-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.rg_ops.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  solutions           = ["VMInsights"]
  tags                = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. HUB VIRTUAL NETWORK
# ---------------------------------------------------------------------------------------------------------------------
module "hub_network" {
  source                 = "../../modules/hub_network"
  vnet_name              = "vnet-hub-${var.environment}-${var.location}"
  location               = var.location
  resource_group_name    = module.rg_hub.name
  address_space          = var.hub_address_space
  firewall_subnet_cidr   = var.firewall_subnet_cidr
  bastion_subnet_cidr    = var.bastion_subnet_cidr
  gateway_subnet_cidr    = var.gateway_subnet_cidr
  management_subnet_name = "snet-hub-mgmt"
  management_subnet_cidr = var.hub_management_subnet_cidr
  tags                   = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. AZURE FIREWALL (CENTRAL EGRESS & INSPECTION ENGINE)
# ---------------------------------------------------------------------------------------------------------------------
module "azure_firewall" {
  source                     = "../../modules/azure_firewall"
  name                       = "afw-hub-${var.environment}-${var.location}"
  location                   = var.location
  resource_group_name        = module.rg_hub.name
  subnet_id                  = module.hub_network.firewall_subnet_id
  public_ip_name             = "pip-afw-${var.environment}-${var.location}"
  firewall_policy_name       = "afwp-hub-${var.environment}-${var.location}"
  sku_tier                   = var.firewall_sku_tier
  availability_zones         = var.firewall_zones
  allowed_source_cidrs       = concat(var.hub_address_space, var.spoke1_address_space, var.spoke2_address_space)
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 5. AZURE BASTION HOST
# ---------------------------------------------------------------------------------------------------------------------
module "azure_bastion" {
  source                     = "../../modules/azure_bastion"
  name                       = "bas-hub-${var.environment}-${var.location}"
  location                   = var.location
  resource_group_name        = module.rg_hub.name
  subnet_id                  = module.hub_network.bastion_subnet_id
  public_ip_name             = "pip-bas-${var.environment}-${var.location}"
  sku                        = "Basic"
  scale_units                = 2
  copy_paste_enabled         = true
  file_copy_enabled          = false
  tunneling_enabled          = false
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 6. SPOKE NETWORKS (WORKLOADS & DATA)
# ---------------------------------------------------------------------------------------------------------------------
module "spoke1" {
  source              = "../../modules/spoke_network"
  vnet_name           = "vnet-spoke-workloads-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.rg_spoke1.name
  address_space       = var.spoke1_address_space
  subnets             = var.spoke1_subnets
  tags                = var.tags
}

module "spoke2" {
  source              = "../../modules/spoke_network"
  vnet_name           = "vnet-spoke-data-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.rg_spoke2.name
  address_space       = var.spoke2_address_space
  subnets             = var.spoke2_subnets
  tags                = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 7. BI-DIRECTIONAL VNET PEERING
# ---------------------------------------------------------------------------------------------------------------------
module "peering_hub_spoke1" {
  source                    = "../../modules/vnet_peering"
  hub_vnet_name             = module.hub_network.vnet_name
  hub_vnet_id               = module.hub_network.vnet_id
  hub_resource_group_name   = module.rg_hub.name
  spoke_vnet_name           = module.spoke1.vnet_name
  spoke_vnet_id             = module.spoke1.vnet_id
  spoke_resource_group_name = module.rg_spoke1.name
  allow_forwarded_traffic   = true
}

module "peering_hub_spoke2" {
  source                    = "../../modules/vnet_peering"
  hub_vnet_name             = module.hub_network.vnet_name
  hub_vnet_id               = module.hub_network.vnet_id
  hub_resource_group_name   = module.rg_hub.name
  spoke_vnet_name           = module.spoke2.vnet_name
  spoke_vnet_id             = module.spoke2.vnet_id
  spoke_resource_group_name = module.rg_spoke2.name
  allow_forwarded_traffic   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# 8. ROUTE TABLES & USER-DEFINED ROUTES
# ---------------------------------------------------------------------------------------------------------------------
module "route_table_spokes" {
  source              = "../../modules/route_table"
  name                = "rt-spokes-to-firewall-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = module.rg_hub.name
  tags                = var.tags

  routes = [
    {
      name                   = "Route-To-Internet-Via-Firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall.private_ip_address
    },
    {
      name                   = "Route-Spoke1-To-Firewall"
      address_prefix         = var.spoke1_address_space[0]
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall.private_ip_address
    },
    {
      name                   = "Route-Spoke2-To-Firewall"
      address_prefix         = var.spoke2_address_space[0]
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall.private_ip_address
    }
  ]

  subnet_ids = [
    module.spoke1.subnet_ids["snet-web"],
    module.spoke1.subnet_ids["snet-app"],
    module.spoke2.subnet_ids["snet-db"]
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# 9. NETWORK SECURITY GROUPS (MICRO-SEGMENTATION)
# ---------------------------------------------------------------------------------------------------------------------
module "nsg_web" {
  source                     = "../../modules/nsg"
  name                       = "nsg-spoke-web-${var.environment}-${var.location}"
  location                   = var.location
  resource_group_name        = module.rg_spoke1.name
  subnet_ids                 = [module.spoke1.subnet_ids["snet-web"]]
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags

  security_rules = [
    {
      name                       = "Allow-HTTPS-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from Virtual Network and Load Balancers"
    },
    {
      name                       = "Allow-HTTP-Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "80"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTP for redirection"
    },
    {
      name                       = "Deny-Direct-Internet-Inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Block unsolicited direct Internet traffic"
    }
  ]
}

module "nsg_app" {
  source                     = "../../modules/nsg"
  name                       = "nsg-spoke-app-${var.environment}-${var.location}"
  location                   = var.location
  resource_group_name        = module.rg_spoke1.name
  subnet_ids                 = [module.spoke1.subnet_ids["snet-app"]]
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags

  security_rules = [
    {
      name                       = "Allow-Web-To-App-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = ["8080", "8443", "443"]
      source_address_prefixes    = var.spoke1_subnets["snet-web"].address_prefixes
      destination_address_prefix = "*"
      description                = "Allow app ports strictly from Web tier subnet"
    },
    {
      name                       = "Deny-All-Other-Inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Default deny other inbound traffic"
    }
  ]
}

module "nsg_db" {
  source                     = "../../modules/nsg"
  name                       = "nsg-spoke-db-${var.environment}-${var.location}"
  location                   = var.location
  resource_group_name        = module.rg_spoke2.name
  subnet_ids                 = [module.spoke2.subnet_ids["snet-db"]]
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags

  security_rules = [
    {
      name                       = "Allow-App-To-DB-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = ["1433", "3306", "5432"]
      source_address_prefixes    = var.spoke1_subnets["snet-app"].address_prefixes
      destination_address_prefix = "*"
      description                = "Allow DB ports strictly from App tier subnet"
    },
    {
      name                       = "Deny-Direct-Internet-Inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Block all direct internet access into DB subnet"
    }
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# 10. AZURE MONITOR ALERTS & NOTIFICATIONS
# ---------------------------------------------------------------------------------------------------------------------
module "azure_monitor" {
  source                     = "../../modules/azure_monitor"
  action_group_name          = "ag-alz-${var.environment}"
  action_group_short_name    = "agalz${var.environment}"
  resource_group_name        = module.rg_ops.name
  location                   = var.location
  firewall_id                = module.azure_firewall.id
  log_analytics_workspace_id = module.log_analytics.id
  email_receivers            = var.alert_email_receivers
  tags                       = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 11. AZURE RBAC ACCESS CONTROL
# ---------------------------------------------------------------------------------------------------------------------
module "rbac" {
  source           = "../../modules/rbac"
  role_assignments = var.rbac_role_assignments
}
