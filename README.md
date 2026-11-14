# Enterprise Azure Landing Zone Deployment using Terraform & Azure DevOps

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-CI%2FCD-0078D7?logo=azure-devops)](https://azure.microsoft.com/services/devops/)
[![Architecture](https://img.shields.io/badge/Architecture-Hub%20%26%20Spoke-brightgreen)]()

An enterprise-ready, production-grade **Azure Landing Zone (ALZ)** based on Microsoft Cloud Adoption Framework (CAF) principles. Implemented using clean, reusable Terraform modules and orchestrated with an automated Azure DevOps YAML multi-stage pipeline.

---

## Architecture Overview

```
                          ┌─────────────────────────────────────┐
                          │         Corporate Network           │
                          │        (On-Prem / VPN Users)        │
                          └──────────────────┬──────────────────┘
                                             │ ExpressRoute / VPN
                                             ▼
       ┌─────────────────────────────────────────────────────────────────────────┐
       │                   Hub Virtual Network (10.0.0.0/16)                     │
       │                                                                         │
       │  ┌───────────────────────┐                    ┌──────────────────────┐  │
       │  │  AzureFirewallSubnet  │                    │  AzureBastionSubnet  │  │
       │  │     10.0.1.0/26       │                    │     10.0.2.0/26      │  │
       │  │   [ Azure Firewall ]  │                    │  [ Azure Bastion ]   │  │
       │  └───────────┬───────────┘                    └──────────────────────┘  │
       │              │ UDR Next-Hop (10.0.1.4)                                  │
       │  ┌───────────┴───────────┐                    ┌──────────────────────┐  │
       │  │     GatewaySubnet     │                    │     snet-hub-mgmt    │  │
       │  │    10.0.255.0/27      │                    │     10.0.10.0/24     │  │
       │  └───────────────────────┘                    └──────────────────────┘  │
       └──────────────────┬──────────────────────────────────┬───────────────────┘
                          │ VNet Peering                     │ VNet Peering
                          │ (Transitive via AFW)             │ (Transitive via AFW)
                          ▼                                  ▼
       ┌──────────────────────────────────────┐  ┌───────────────────────────────┐
       │     Spoke 1: Workloads Network       │  │   Spoke 2: Data Platform      │
       │            (10.1.0.0/16)             │  │         (10.2.0.0/16)         │
       │                                      │  │                               │
       │  ┌───────────────┐  ┌──────────────┐ │  │ ┌──────────────┐ ┌──────────┐ │
       │  │   snet-web    │  │   snet-app   │ │  │ │   snet-db    │ │   snet-    │ │
       │  │  10.1.1.0/24  │  │ 10.1.2.0/24  │ │  │ │ 10.2.1.0/24 │ │  private-  │ │
       │  │ (nsg-spoke-web│  │(nsg-spoke-app│ │  │ │(nsg-spoke-db│ │ endpoints │ │
       │  └───────────────┘  └──────────────┘ │  │ └──────────────┘ └──────────┘ │
       └──────────────────────────────────────┘  └───────────────────────────────┘
```

---

## Key Features & Production Highlights

- **Hub-and-Spoke Topology**: Complete isolation of shared services (Hub) from application and data workloads (Spokes).
- **Centralized Security Inspection**: All outbound and inter-spoke traffic is forced through **Azure Firewall** via User Defined Routes (UDRs `0.0.0.0/0 -> 10.0.1.4`).
- **Zero Public IP Bastion Access**: Virtual machines in private subnets have zero public IP exposure; connectivity is brokered via **Azure Bastion Standard** with native tunneling & audit logging.
- **Micro-Segmentation (NSGs)**: Granular Network Security Groups on each subnet enforce least privilege access (Web -> App -> DB).
- **Observability & Alerting**: Centralized **Log Analytics Workspace** collects diagnostic logs from Firewall, Bastion, and NSGs, backed by **Azure Monitor metric & scheduled query alerts** (Firewall Health, SNAT exhaustion, Denied traffic spikes).
- **Multi-Environment Separation**: Distinct `dev` and `prod` environments with separate variable parameters, retention policies, and zone redundancy.
- **Azure DevOps CI/CD Multi-Stage Pipeline**:
  - Automated formatting and `tfsec` static security vulnerability scanning.
  - Plan artifact generation with cross-stage validation.
  - Manual approval gate for production apply.
- **Automated Backend Bootstrapping**: Ready-to-run Bash & PowerShell scripts to initialize Geo-Redundant Azure Blob storage for Terraform state.

---

## Repository Structure

```
Azure_LD/
├── .azure-pipelines/
│   └── azure-pipelines.yml          # Multi-stage Azure DevOps CI/CD pipeline
├── docs/
│   └── LLD.md                       # Comprehensive Low-Level Design document
├── environments/
│   ├── dev/                         # Development environment root
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── prod/                        # Production environment root
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       └── versions.tf
├── modules/
│   ├── azure_bastion/               # Azure Bastion Host + Public IP + Diag
│   ├── azure_firewall/              # Azure Firewall + Policy + Rule Groups + Diag
│   ├── azure_monitor/               # Action Groups + Metric Alerts + Query Alerts
│   ├── hub_network/                 # Hub VNet + Firewall/Bastion/Gateway Subnets
│   ├── log_analytics/               # Log Analytics Workspace + Solutions
│   ├── nsg/                         # Network Security Groups + Rules + Diag
│   ├── rbac/                        # Azure RBAC role assignments
│   ├── resource_group/              # Azure Resource Group
│   ├── route_table/                 # Route Tables & UDR next-hop routing
│   ├── spoke_network/               # Spoke VNet + Subnets + Delegations
│   └── vnet_peering/                # Bi-directional VNet Peering
├── scripts/
│   ├── init-backend.sh              # Bash script to create remote state storage
│   └── init-backend.ps1             # PowerShell script to create remote state storage
└── README.md
```

---

## Quickstart & Deployment Guide

### Prerequisites
1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (`>= 2.50.0`)
2. [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (`>= 1.5.0`)
3. Azure subscription with Owner or Contributor + User Access Administrator permissions.

---

### Step 1: Bootstrap Remote State Storage

Run the bootstrapping script to create the Azure Resource Group, GRS Storage Account, and private container:

**Using PowerShell:**
```powershell
.\scripts\init-backend.ps1 -Environment "prod" -Location "eastus"
```

**Using Bash:**
```bash
chmod +x ./scripts/init-backend.sh
./scripts/init-backend.sh prod eastus
```

---

### Step 2: Local Terraform Deployment (Optional)

Navigate to the target environment (`environments/prod` or `environments/dev`):

```bash
cd environments/prod

# Initialize Terraform with the backend created in Step 1
terraform init \
  -backend-config="resource_group_name=rg-terraform-state-prod" \
  -backend-config="storage_account_name=<YOUR_STORAGE_ACCOUNT>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=landingzone.prod.tfstate"

# Review execution plan
terraform plan

# Apply infrastructure changes
terraform apply
```

---

### Step 3: Automated Azure DevOps CI/CD Deployment

1. **Create an Azure DevOps Service Connection**:
   - Go to **Project Settings** > **Service Connections** > **New Service Connection** > **Azure Resource Manager**.
   - Select **Service Principal (automatic or manual)**.
   - Name the connection `sc-azure-landingzone-sp`.
2. **Configure Pipeline Environments**:
   - Go to **Pipelines** > **Environments**.
   - Create environment `LandingZone-Dev`.
   - Create environment `LandingZone-Production` and add **Approvals and checks** with your designated senior DevOps/SecOps reviewers.
3. **Run Pipeline**:
   - Point your Azure DevOps pipeline to `.azure-pipelines/azure-pipelines.yml`.
   - On pull requests or commits to `main`, the pipeline validates, tests, and safely deploys to Dev and Prod.

---

## Verification & Testing

Once deployed, verify the landing zone connectivity and policies:

1. **Verify VNet Peering State**:
   ```bash
   az network vnet peering list \
     --resource-group rg-hub-prod-eastus \
     --vnet-name vnet-hub-prod-eastus \
     --query "[].{Name:name, State:peeringState}" -o table
   ```
2. **Verify Firewall Private IP and Status**:
   ```bash
   az network firewall show \
     --name afw-hub-prod-eastus \
     --resource-group rg-hub-prod-eastus \
     --query "{Name:name, ProvisioningState:provisioningState, PrivateIP:ipConfigurations[0].privateIpAddress}" -o table
   ```
3. **Verify Bastion Host Connectivity**:
   ```bash
   az network bastion show \
     --name bas-hub-prod-eastus \
     --resource-group rg-hub-prod-eastus \
     --query "{Name:name, ProvisioningState:provisioningState, DNS:dnsName}" -o table
   ```

---

## License & Author
- **Author:** Cloud & DevOps Engineering Team
- **Standard:** Microsoft Cloud Adoption Framework (CAF)

