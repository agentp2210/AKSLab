#!/bin/bash
cd $(dirname "$0")

acr=$(az acr list --query "[].loginServer" -o tsv)
az acr login --name $acr

# Remove image if exist
existing_image=$(docker images | grep sampleapp | awk '{print $1}')
docker rmi $existing_image

docker build -t $acr/dotnet/sampleapp:latest ../aspnet-core-dotnet-core/Dockerfile
docker push $acr/dotnet/sampleapp:latest