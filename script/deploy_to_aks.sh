#!/bin/bash
cd $(dirname "$0")
set -x

cd ./terraform
# Create secret
instrumentation_key=$(terraform output instrumentation_key)
kubectl -n default create secret generic aikey --from-literal=aisecret=$instrumentation_key
