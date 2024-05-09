#!/bin/bash
cd $(dirname "$0")

acr=$(az acr list --query "[].loginServer" -o tsv)
az acr login --name $acr

myAKSClusterACR18691/samples/hello-world
docker build -t $acr/dotnet/sampleapp:latest .
docker push $acr/dotnet/sampleapp:latest