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
}

# Define the Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  location            = var.keyvault_location
  resource_group_name = var.keyvault_resource_group_name
  tenant_id           = var.keyvault_tenant_id 


  # Configuration for the Key Vault
  sku_name            = "standard"
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
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
}