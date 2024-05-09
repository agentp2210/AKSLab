#!/bin/bash
cd $(dirname "$0")

acr=$(az acr list --query "[].loginServer" -o tsv)
az acr login --name $acr

docker build -t $acr/dotnet/sampleapp:latest .
docker push $acr/dotnet/sampleapp:latest