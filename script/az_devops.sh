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



echo "Creating service connection to GitHub: $service_connection_github"
export AZURE_DEVOPS_EXT_GITHUB_PAT=$AZURE_DEVOPS_EXT_GITHUB_PAT
# Script will continue if failed because using || true
az devops service-endpoint github create --github-url $repo --name $service_connection_github || true

# Create a pipeline
PL_name="PL_Terraform_Create_AKS"
pipeline_exist=$(az pipelines list --query "[].name" -o tsv | grep $PL_name)
if [ -z $pipeline_exist]
then
    az pipelines create --org $org_url --project $project --name $PL_name \
        --repository $repo --yml-path "pipelines/PL-Deploy-AKS.yaml" \
        --service-connection $service_connection_az
else
    echo "$PL_name already exist"
fi

# Run the pipeline
# backendAzureRmStorageAccountName=$(az storage account list -g $rg_name --query "[].name" -o tsv | grep "tfstate*")
# az pipelines run --org $org_url --project $project --open true --name $PL_name \
#     --variables "backendAzureRmResourceGroupName=$rg_name \
#     backendAzureRmStorageAccountName=$backendAzureRmStorageAccountName"
    