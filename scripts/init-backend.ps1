<#
.SYNOPSIS
    Bootstrap Azure Storage Account and Blob Container for Terraform Remote State.
.DESCRIPTION
    Creates Resource Group, Geo-Redundant Storage Account with TLS 1.2, private blob container,
    and enables versioning + soft-delete for Terraform state storage.
.EXAMPLE
    .\init-backend.ps1 -Environment "prod" -Location "eastus"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("prod", "dev", "staging")]
    [string]$Environment = "prod",

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId
)

$ErrorActionPreference = "Stop"

if (-not $SubscriptionId) {
    $SubscriptionId = (az account show --query id -o tsv)
}

$RandomSuffix = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
$ResourceGroupName = "rg-terraform-state-$Environment"
$StorageAccountName = "sttfstate$Environment$RandomSuffix"
$ContainerName = "tfstate"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Bootstrapping Terraform Remote Backend for [$Environment]" -ForegroundColor Cyan
Write-Host " Location:          $Location" -ForegroundColor Cyan
Write-Host " Resource Group:     $ResourceGroupName" -ForegroundColor Cyan
Write-Host " Storage Account:    $StorageAccountName" -ForegroundColor Cyan
Write-Host " Container Name:     $ContainerName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

az account set --subscription $SubscriptionId

# 1. Create Resource Group
Write-Host "Creating Resource Group..." -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --tags Environment=$Environment ManagedBy="BootstrapScript" Project="Azure-Landing-Zone" | Out-Null

# 2. Create Storage Account
Write-Host "Creating Storage Account..." -ForegroundColor Yellow
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku "Standard_GRS" `
    --kind "StorageV2" `
    --min-tls-version "TLS1_2" `
    --allow-blob-public-access false `
    --tags Environment=$Environment ManagedBy="BootstrapScript" Project="Azure-Landing-Zone" | Out-Null

# 3. Create Blob Container
Write-Host "Creating Blob Container..." -ForegroundColor Yellow
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login | Out-Null

# 4. Enable Blob Versioning & Soft Delete
Write-Host "Enabling Blob Versioning & Soft Delete..." -ForegroundColor Yellow
az storage account blob-service-properties update `
    --account-name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --enable-versioning true `
    --enable-delete-retention true `
    --delete-retention-days 14 | Out-Null

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Remote State Backend created successfully!" -ForegroundColor Green
Write-Host " Run 'terraform init' with these backend configs:" -ForegroundColor White
Write-Host " terraform init ``"
Write-Host "   -backend-config=""resource_group_name=$ResourceGroupName"" ``"
Write-Host "   -backend-config=""storage_account_name=$StorageAccountName"" ``"
Write-Host "   -backend-config=""container_name=$ContainerName"" ``"
Write-Host "   -backend-config=""key=landingzone.$Environment.tfstate"""
Write-Host "==========================================================" -ForegroundColor Green

