# Select Subscription
az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"

# Create RG & AKS Cluster with OIDC Issuer enabled
az group create --name rg-tiks-dev-switzerlandnorth-001 --location switzerlandnorth
az aks update -g rg-tiks-dev-switzerlandnorth-001 -n aks-tiks-dev-switzerland --enable-oidc-issuer --enable-workload-identity


# Assign OIDC Endpoints / Subscription IDs variables
export AKS_OIDC_ISSUER="$(az aks show -n aks-tiks-dev-switzerland -g rg-tiks-dev-switzerlandnorth-001 --query "oidcIssuerProfile.issuerUrl" -otsv)"
export SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
export USER_ASSIGNED_IDENTITY_NAME="tiks"
export RG_NAME="rg-tiks-dev-switzerlandnorth-001"
export LOCATION="switzerlandnorth"

# Create Managed Identity on AAD 
az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RG_NAME}" --location "${LOCATION}" --subscription "${SUBSCRIPTION_ID}"
export RG_NAME="rg-tiks-dev-switzerlandnorth-001"
export USER_ASSIGNED_IDENTITY_NAME="tiks"
export KEYVAULT_NAME="kvtiksdev001"
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${RG_NAME}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -otsv)"

# Create Key Vault (For Testing Later) 
az keyvault set-policy --name "${KEYVAULT_NAME}" --secret-permissions get --spn "${USER_ASSIGNED_CLIENT_ID}"

# Authenticate to Kubernetes
az aks get-credentials -n aks-tiks-dev-switzerland -g rg-tiks-dev-switzerlandnorth-001

# Create a namespace and service account 
export SERVICE_ACCOUNT_NAME="workload-identity-sa"
export SERVICE_ACCOUNT_NAMESPACE="tiks"
kubectl create namespace "${SERVICE_ACCOUNT_NAMESPACE}"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
  labels:
    azure.workload.identity/use: "true"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF

# Setup federation on managed identity (this configures trust relationship between AKS and AAD) 
az identity federated-credential create --name tiks --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RG_NAME}" --issuer "${AKS_OIDC_ISSUER}" --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${SERVICE_ACCOUNT_NAME}"

az aks update -n aks-tiks-dev-switzerland -g rg-tiks-dev-switzerlandnorth-001 --attach-acr crtiksdevcontainerregistry


# Test if identity works
#cat <<EOF | kubectl apply -f -
#apiVersion: v1
#kind: Pod
#metadata:
#  name: cli
#  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
#spec:
#  serviceAccountName: ${SERVICE_ACCOUNT_NAME}
#  containers:
#    - image: mcr.microsoft.com/azure-cli:latest
#      name: cli
#      command:
#        - "/bin/bash"
#        - "-c"
#        - "sleep infinity"
#  nodeSelector:
#    kubernetes.io/os: linux
#EOF
#
#kubectl describe pod --namespace tiks cli
#
## Connect to the Pod
#kubectl exec -it --namespace tiks cli /bin/bash
#
#cat /var/run/secrets/azure/tokens/azure-identity-token
#
#az login --federated-token "$(cat /var/run/secrets/azure/tokens/azure-identity-token)" --debug --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID