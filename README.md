# This lab create an AKS cluster using Terraform

# Step 1: Login to az cli
``` shell
./script/az_login.sh
```

# Step 2: Create the remote backend
``` shell
./script/create_tf_backend.sh
```

# Step 3: Create AKS cluster
``` shell
./script/create_AKS.sh
```

# Step 4: Build docker image and push to ACR
``` shell
./script/pushToACR.sh
```

# Step 5: Deploy to AKS
``` shell
./script/deploy_to_aks.sh
```

# Deploy EFK for logging
``` shell
helm install elasticsearch oci://registry-1.docker.io/bitnamicharts/elasticsearch -n logging -f EFK/es-values.yaml --create-namespace

```