#!/bin/bash
cd "$(dirname "$0")"

read -p "Service Principal ID: " sp_id
read -p "Service Principal secret: " sp_key


org_url="https://dev.azure.com/myAKSLabOrg"
project=$(az devops project list --org $org_url --query "value[0].name" -o tsv)
service_connection="az-svc-connection"
tenantId=$(az account show --query "tenantId" -o tsv)
subscription_id=$(az account show --query "id" -o tsv)
subscription_name=$(az account show --query "name" -o tsv)
rg_name=$(az group list --query "[].name" -o tsv)

# Set service principal secret using env var
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$sp_key

# Create service connection
echo "Creating service connection: $service_connection"
az devops service-endpoint azurerm create --azure-rm-service-principal-id $sp_id\
    --azure-rm-subscription-id $subscription_id \
    --azure-rm-subscription-name "$subscription_name" \
    --azure-rm-tenant-id $tenantId \
    --name $service_connection \
    --org $org_url --project $project

# Create a pipeline
PL_name="PL_Terraform_Create_AKS"
repo="https://github.com/agentp2210/AKSLab"
backendAzureRmStorageAccountName=$(az storage account list -g $rg_name --query "[].name" -o tsv | grep "tfstate*")

az pipelines create --org $org_url --project $project --name $PL_name \
    --repository $repo

# Run the pipeline
az pipelines run --org $org_url --project $project --open true --name $PL_name \
    --variables "backendAzureRmResourceGroupName=$rg_name \
    backendAzureRmStorageAccountName=$backendAzureRmStorageAccountName"
    