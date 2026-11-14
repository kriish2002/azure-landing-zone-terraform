#!/usr/bin/env bash
# ==============================================================================
# Script: init-backend.sh
# Purpose: Bootstrap Azure Storage Account & Blob Container for Terraform Remote State
# ==============================================================================

set -euo pipefail

ENV=${1:-"prod"}
LOCATION=${2:-"eastus"}
SUBSCRIPTION_ID=${3:-$(az account show --query id -o tsv)}

RESOURCE_GROUP_NAME="rg-terraform-state-${ENV}"
STORAGE_ACCOUNT_NAME="sttfstate${ENV}$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
CONTAINER_NAME="tfstate"

echo "=========================================================="
echo " Bootstrapping Terraform Remote Backend for [${ENV}]"
echo " Location:          ${LOCATION}"
echo " Resource Group:     ${RESOURCE_GROUP_NAME}"
echo " Storage Account:    ${STORAGE_ACCOUNT_NAME}"
echo " Container Name:     ${CONTAINER_NAME}"
echo "=========================================================="

az account set --subscription "${SUBSCRIPTION_ID}"

# 1. Create Resource Group
echo "Creating Resource Group..."
az group create \
  --name "${RESOURCE_GROUP_NAME}" \
  --location "${LOCATION}" \
  --tags Environment="${ENV}" ManagedBy="BootstrapScript" Project="Azure-Landing-Zone"

# 2. Create Storage Account (Standard_GRS with TLS 1.2 and blob encryption)
echo "Creating Storage Account..."
az storage account create \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --location "${LOCATION}" \
  --sku "Standard_GRS" \
  --kind "StorageV2" \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false \
  --enable-hierarchical-namespace false \
  --tags Environment="${ENV}" ManagedBy="BootstrapScript" Project="Azure-Landing-Zone"

# 3. Create Blob Container
echo "Creating Blob Container..."
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login

# 4. Enable Blob Versioning and Soft Delete
echo "Enabling Blob Versioning & Soft Delete for disaster recovery..."
az storage account blob-service-properties update \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14

echo "=========================================================="
echo " Remote State Backend created successfully!"
echo " Use the following for 'terraform init':"
echo "   terraform init \\"
echo "     -backend-config=\"resource_group_name=${RESOURCE_GROUP_NAME}\" \\"
echo "     -backend-config=\"storage_account_name=${STORAGE_ACCOUNT_NAME}\" \\"
echo "     -backend-config=\"container_name=${CONTAINER_NAME}\" \\"
echo "     -backend-config=\"key=landingzone.${ENV}.tfstate\""
echo "=========================================================="

