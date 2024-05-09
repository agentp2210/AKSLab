#!/bin/bash
cd "$(dirname "$0")"

read -p "Service principal ID: " sp_id
read -p "Service principal secret: " sp_secret

rg_name=$(az group list --query "[].name" -o tsv)
rg_id=$(az group list --query "[].id" -o tsv)
location=$(az group list --query "[].location" -o tsv)

cd ../terraform
terraform plan -var="client_id=$sp_id" -var="client_secret=$sp_secret" \
    -var="resource_group_name=$rg_name" -var="rg_id=$rg_id" -var="location=$location" \
    -var-file="./vars/dev.tfvars" -out aks.tfplan
terraform apply aks.tfplan

# Configure kube config after AKS cluster is created
kube_config=kubeconfig
terraform output kube_config > $kube_config
sed -i '1d' $kube_config
sed -i '$d' $kube_config
export KUBECONFIG="./$kube_config"

kubectl get node