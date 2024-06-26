#!/bin/bash
cd "$(dirname "$0")"

rg_name=$(az group list --query "[].name" -o tsv)
rg_id=$(az group list --query "[].id" -o tsv)
location=$(az group list --query "[].location" -o tsv)

# Create a storage account for Terraform remnote backend
cd ../terraform-backend
rm -r .terraform
rm terraform.tfstate
terraform init
terraform plan -var="resource_group_name=$rg_name" -var="rg_id=$rg_id" -var="location=$location" -out plan.tfplan
terraform apply plan.tfplan

# Get the remote backend details from the outputs.
# To remove the "" from a string, use tr -d
storage_account_name=$(terraform output storage_account_name | tr -d '"')
container_name=$(terraform output container_name | tr -d '"')

# Use the remote backend in the main configuration
cd ../terraform
rm -r .terraform

terraform init \
    -backend-config="resource_group_name=$rg_name" \
    -backend-config="storage_account_name=$storage_account_name" \
    -backend-config="container_name=$container_name" \
    -backend-config="key=terraform.tfstate"



