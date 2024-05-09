#!/bin/bash
cd $(dirname "$0")
set -x

cd ../terraform
# Create secret
instrumentation_key=$(terraform output instrumentation_key | tr -d '"')
kubectl -n default create secret generic aikey --from-literal=aisecret=$instrumentation_key

kubectl apply -f ../k8s_manifest/aspnet.yaml 
