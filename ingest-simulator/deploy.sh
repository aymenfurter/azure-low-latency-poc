#!/usr/bin/env bash

# Set the name of the Docker image
IMAGE_NAME=ingest-simulator

# Set the name of the ACR registry
# ACR_NAME=myacr

# Set the name of the AKS cluster
# AKS_NAME=myaks

if [[ -z "$AKS_NAME" || -z "$ACR_NAME" ]]; then
    # Print an error message and show the usage of the script
    >&2 echo -e "\e[31mError: The AKS_NAME and ACR_NAME environment variables are not set.\e[0m"
    echo "Usage: AKS_NAME=<aks-cluster-name> ACR_NAME=<acr-registry-name> $0"
    exit 1
fi

if ! command -v kubectl > /dev/null 2>&1; then
    printf "\033[0;31mError: kubectl command not found\033[0m\n"
    exit 1
fi

if ! command -v docker > /dev/null 2>&1; then
    printf "\033[0;31mError: kubectl command not found\033[0m\n"
    exit 1
fi

# Build the Docker image for the ingest-simulator application
docker build -t $IMAGE_NAME .

# Push the Docker image to ACR
docker tag $IMAGE_NAME $ACR_NAME.azurecr.io/$IMAGE_NAME
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME

# Deploy the Docker image to AKS
kubectl apply -f yaml/deployment.yaml
kubectl set image deployment/$IMAGE_NAME $IMAGE_NAME=$ACR_NAME.azurecr.io/$IMAGE_NAME