# This lab create an AKS cluster using Terraform

# Step 1: Login to az cli
./script/az_login.sh

# Step 2: Create the remote backend
./script/create_tf_backend.sh

# Step 3: Create AKS cluster
./script/create_AKS.sh

# Step 4: Build docker image and push to ACR

