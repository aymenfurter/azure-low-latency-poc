# Variables for the AKS cluster
variable "aks_name" {
  type = string
  default = "aks-cluster"
}

variable "aks_location" {
  type = string
  default = "Switzerland North"
}

variable "aks_resource_group_name" {
  type = string
  default = "aks-resource-group"
}

variable "aks_dns_prefix" {
  type = string
  default = "aks-cluster"
}

variable "aks_identity_id" {
  type = string
  default = "aks-identity-id"
}

variable "aks_log_analytics_workspace_id" {
  type = string
  default = "workspace-id"
}

# Variables for the Event Hub
variable "eventhub_namespace_name" {
  type = string
  default = "eventhub-namespace"
}

variable "eventhub_location" {
  type = string
  default = "Switzerland North"
}

variable "eventhub_resource_group_name" {
  type = string
  default = "aks-resource-group"
}

variable "eventhub_name" {
  type = string
  default = "eventhubtopic"
}

# Variables for the key vault
variable "keyvault_name" {
  type = string
  default = "keyvault"
}

variable "keyvault_location" {
  type = string
  default = "Switzerland North"
}

variable "keyvault_resource_group_name" {
  type = string
  default = "aks-resource-group"
}

variable "keyvault_tenant_id" {
  type = string
}

# Variables for the container registry
variable "container_registry_name" {
  type = string
  # generate compliant name as per azure naming convention ending with numbers
  default = "cregilowlattest001"
}

variable "container_registry_location" {
  type = string
  default = "Switzerland North"
}

variable "container_registry_resource_group_name" {
  type = string
  default = "aks-resource-group"
}

# Variables for the AKS node pool
variable "aks_node_pool_name" {
  type = string
  default = "default"
}

variable "aks_node_count" {
  type = number
  default = 1
}

variable "aks_vm_size" {
  type = string
  default = "Standard_DS1_v2"
}

# Variables for the AKS cluster
variable "aks_cluster_name" {
  type = string
  default = "aks-cluster"
}

variable "aks_kubernetes_version" {
  type = string
  default = "1.25.4"
}

# Variables for the Event Hub namespace
variable "eventhub_namespace_capacity" {
  type = number
  default = 1
}


# Declare the name of the new Event Hub topic
variable "eventhub_topic_name" {
  description = "The name of the new Event Hub topic"
  type        = string
  default     = "ticks"
}

# Declare the partition count configuration for the new Event Hub topic
variable "eventhub_topic_partition_count" {
  description = "The partition count configuration for the new Event Hub topic"
  type        = string
  default     = "2"
}

# Declare the message retention configuration for the new Event Hub topic
variable "eventhub_topic_message_retention" {
  description = "The message retention configuration for the new Event Hub topic"
  type        = string
  default     = "1"
}
