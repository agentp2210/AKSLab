#!/bin/bash
cd "$(dirname "$0")"

read -p "Service Principal ID: " sp_id
read -p "Service Principal secret: " sp_key
read -p "AZURE_DEVOPS_EXT_GITHUB_PAT: " AZURE_DEVOPS_EXT_GITHUB_PAT
read -p "Az DevOps Org name: " org

org_url="https://dev.azure.com/$org"
project=$(az devops project list --org $org_url --query "value[0].name" -o tsv)
service_connection_az="az-svc-connection"
service_connection_github="github-svc-connection"
repo="https://github.com/agentp2210/AKSLab"
tenantId=$(az account show --query "tenantId" -o tsv)
subscription_id=$(az account show --query "id" -o tsv)
subscription_name=$(az account show --query "name" -o tsv)
rg_name=$(az group list --query "[].name" -o tsv)

# Set service principal secret using env var
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$sp_key

# Set Default DevOps Organisation and Project:
az devops configure --defaults organization=$org_url project=$project

# Create service connection
connection_exist=$(az devops service-endpoint list --query "[].name" -o tsv | grep $service_connection_az)
if [ -z "$connection_exist" ]
then
    echo "Creating service connection to Azure: $service_connection_az"
    az devops service-endpoint azurerm create --azure-rm-service-principal-id $sp_id \
        --azure-rm-subscription-id $subscription_id \
        --azure-rm-subscription-name "$subscription_name" \
        --azure-rm-tenant-id $tenantId \
        --name $service_connection_az
else
    echo "$service_connection_az already exist"
fi

export AZURE_DEVOPS_EXT_GITHUB_PAT=$AZURE_DEVOPS_EXT_GITHUB_PAT

# Create an Azure Repo and import code from GitHub
az_repo_id=$(az repos list --query "[].id" -o tsv)
az_repo_name=$(az repos list --query "[].name" -o tsv)
az repos import create --git-url $repo --repository $az_repo_id || true

# Install Terraform extension
az devops extension install --extension-id "custom-terraform-tasks" --publisher-id ms-devlabs

# Create a pipeline
PL_name="PL_Terraform_Create_AKS"
pipeline_exist=$(az pipelines list --query "[].name" -o tsv | grep $PL_name)
if [ -z $pipeline_exist]
then
    connection_id=$(echo $(az devops service-endpoint list --query "[].{id:id, name:name}" -o tsv | grep $service_connection_github) | cut -d " " -f1)
    az pipelines create --name $PL_name --skip-run true \
        --repository $az_repo_name --branch main --repository-type tfsgit \
        --yml-path "pipelines/PL-Deploy-AKS.yaml"
else
    echo "$PL_name already exist"
fi

# Run the pipeline
backendAzureRmStorageAccountName=$(az storage account list -g $rg_name --query "[].name" -o tsv | grep "tfstate*")
az pipelines run --org $org_url --project $project --name $PL_name \
    --variables "backendAzureRmResourceGroupName=$rg_name \
    backendAzureRmStorageAccountName=$backendAzureRmStorageAccountName"
    