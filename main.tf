# Define the Event Hub namespace
resource "azurerm_eventhub_namespace" "eventhub" {
  name                = var.eventhub_namespace_name
  location            = var.eventhub_location
  resource_group_name = var.eventhub_resource_group_name

  # Configuration for the Event Hub namespace
  capacity            = var.eventhub_namespace_capacity
  sku                 = "Standard"
}

# Define the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.aks_location
  resource_group_name = var.aks_resource_group_name

  # Configuration for the AKS cluster
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.aks_kubernetes_version
  network_profile {
    network_plugin = "kubenet"
  }

  # Configuration for the AKS managed identity
  identity {
    type = "SystemAssigned"
  }

  # Configuration for the default node pool
  default_node_pool {
    name       = var.aks_node_pool_name
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_size
  }

  depends_on          = [azurerm_resource_group.aks]
}

# Define the Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.keyvault_location
  resource_group_name         = var.keyvault_resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7


  # Configuration for the Key Vault
  sku_name            = "standard"
  purge_protection_enabled    = false
  
  depends_on          = [azurerm_resource_group.keyvault]
}


# Define the container registry
resource "azurerm_container_registry" "containerregistry" {
  name                = var.container_registry_name
  location            = var.container_registry_location
  resource_group_name = var.container_registry_resource_group_name

  # Configuration for the container registry
  sku                 = "Standard"
}

# Define the Event Hub authorization rule for the access keys
resource "azurerm_eventhub_authorization_rule" "eventhub_access_keys" {
  name                = "eventhub-access-keys"
  namespace_name      = azurerm_eventhub_namespace.eventhub.name
  resource_group_name = var.eventhub_resource_group_name
  eventhub_name       = azurerm_eventhub.eventhub.name

  # Configuration for the access keys
  listen              = true
  send                = true
  manage              = true

  # Depend on the Event Hub and AKS cluster
  depends_on          = [azurerm_eventhub.eventhub, azurerm_kubernetes_cluster.aks]
}

# Define the key vault secret for the Event Hub access keys
resource "azurerm_key_vault_secret" "eventhub_access_keys" {
  name                = "eventhub-access-keys"
  value               = azurerm_eventhub_authorization_rule.eventhub_access_keys.primary_key
  key_vault_id        = azurerm_key_vault.keyvault.id

  # Depend on the key vault and AKS cluster
  depends_on          = [azurerm_key_vault.keyvault, azurerm_kubernetes_cluster.aks]
}


# Define a new Event Hub topic
resource "azurerm_eventhub" "eventhub" {
  name                = var.eventhub_topic_name
  namespace_name      = azurerm_eventhub_namespace.eventhub.name
  resource_group_name = var.eventhub_resource_group_name

  # Configuration for the new Event Hub topic
  partition_count = var.eventhub_topic_partition_count
  message_retention = var.eventhub_topic_message_retention

  depends_on          = [azurerm_resource_group.eventhub]
}

resource "azurerm_role_assignment" "aks_acr_role_assignment" {
  scope                = azurerm_container_registry.containerregistry.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id

  # Depend on the AKS cluster and container registry
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.containerregistry]
}

# Define the resource group for the Event Hub
resource "azurerm_resource_group" "eventhub" {
  name     = var.eventhub_resource_group_name
  location = var.eventhub_location
}

# Define the resource group for the AKS cluster
resource "azurerm_resource_group" "aks" {
  name     = var.aks_resource_group_name
  location = var.aks_location
}

# Define the resource group for the Key Vault
resource "azurerm_resource_group" "keyvault" {
  name     = var.keyvault_resource_group_name
  location = var.keyvault_location
}

# Define the resource group for the ACR
resource "azurerm_resource_group" "acr" {
  name     = var.container_registry_resource_group_name
  location = var.container_registry_location
}


resource "azurerm_key_vault_access_policy" "personal" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  # Assign the Key Vault administrator role to the current user
  key_permissions = ["Create", "Delete", "Get", "List", "Update", "Import", "Backup", "Restore", "Recover", "Purge"]
  secret_permissions = ["Set", "Get", "List", "Delete", "Recover", "Backup", "Restore", "Purge"]
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Purge"]
}
