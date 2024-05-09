#!/bin/bash
cd "$(dirname "$0")"

rg_name=$(az group list --query "[].name" -o tsv)
rg_id=$(az group list --query "[].id" -o tsv)
location=$(az group list --query "[].location" -o tsv)

cd ../terraform
terraform plan -var="resource_group_name=$rg_name" -var="rg_id=$rg_id" -var="location=$location" -var-file="./vars/dev.tfvars" -out aks.tfplan
terraform apply aks.tfplan