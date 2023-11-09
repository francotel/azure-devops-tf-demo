#!/bin/bash

# Connect and set Subscription Context in Azure
# az login

# Verify current account login
az account show

# Set Variables for Storage account and Key Vault that support the Terraform implementation
SUBSCRIPTION_ID="d871600c-aab8-43c0-97db-6b172da69fce"
RESOURCE_GROUP_NAME="azure-rg-infra"
STORAGE_ACCOUNT_NAME="infrademostate"
CONTAINER_NAME="tstate"
STATE_FILE="terraform.state"
KV_TERRAFORM="kv-terraform-${RANDOM}"
REGION="westus2"

az account set --subscription $SUBSCRIPTION_ID

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $REGION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --allow-blob-public-access false --encryption-services blob

# Get storage account key (Only used if SPN not available)
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

# Show details for the purposes of this code
echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
echo "state_file: $STATE_FILE"

# Create KeyVault and example of storing a key
az keyvault create --name $KV_TERRAFORM --resource-group $RESOURCE_GROUP_NAME --location $REGION
az keyvault secret set --vault-name $KV_TERRAFORM --name "tfstateaccess" --value $ACCOUNT_KEY
az keyvault secret show --vault-name $KV_TERRAFORM --name "tfstateaccess"