#!/bin/bash

# to avoid displaying your password, use -s
read -p "Azure username: " az_username
read -sp "Azure password: " AZ_PASS && echo && az login -u $az_username -p $AZ_PASS

# Add devops extension to use az devops cli
az extension add --name azure-devops
