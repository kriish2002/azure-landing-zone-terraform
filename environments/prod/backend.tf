# Remote state storage configuration
# Uncomment and configure with your Azure Storage Account details, or supply via CLI / Azure DevOps pipeline:
# terraform init \
#   -backend-config="resource_group_name=rg-terraform-state-prod" \
#   -backend-config="storage_account_name=sttfstateprodlandingzone" \
#   -backend-config="container_name=tfstate" \
#   -backend-config="key=landingzone.prod.tfstate"

terraform {
  backend "azurerm" {
    # Set dynamically in CI/CD pipeline or pass via -backend-config
    # resource_group_name  = "rg-terraform-state-prod"
    # storage_account_name = "sttfstateprodlandingzone"
    # container_name       = "tfstate"
    # key                  = "landingzone.prod.tfstate"
  }
}

