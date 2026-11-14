terraform {
  backend "azurerm" {
    # Set dynamically in CI/CD pipeline or pass via -backend-config
    # resource_group_name  = "rg-terraform-state-dev"
    # storage_account_name = "sttfstatedevlandingzone"
    # container_name       = "tfstate"
    # key                  = "landingzone.dev.tfstate"
  }
}

