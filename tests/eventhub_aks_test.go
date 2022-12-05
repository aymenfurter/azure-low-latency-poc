package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/gruntwork-io/terratest/modules/azure"
)

// Test the deployment of AKS and Event Hub
func TestAKSandEventHubDeployment(t *testing.T) {
  terraformOptions := &terraform.Options{
    // The path to where our Terraform code is located
	TerraformDir := "$GITHUB_WORKSPACE"


    // Variables to pass to our Terraform code using -var options
    Vars: map[string]interface{}{
		"aks_cluster_name": "test-aks-cluster",
		"resource_group_name": "test-aks-rg",
		"eventhub_namespace_name": "test-eventhub-namespace",	  
    },
  }

  // At the end of the test, run `terraform destroy` to clean up any resources that were created
  defer terraform.Destroy(t, terraformOptions)

  // This will run `terraform init` and `terraform apply` and fail the test if there are any errors
  terraform.InitAndApply(t, terraformOptions)

  // Retrieve the Azure Resource Group where the AKS cluster was deployed
  resourceGroupName := terraform.Output(t, terraformOptions, "aks_resource_group_name")

  // Retrieve the name of the AKS cluster
  aksClusterName := terraform.Output(t, terraformOptions, "aks_cluster_name")

  // Check that the AKS cluster was created successfully
  azure.AssertAKSClusterExists(t, resourceGroupName, aksClusterName)

  // Retrieve the Azure Resource Group where the Event Hub namespace was deployed
  eventHubResourceGroupName := terraform.Output(t, terraformOptions, "eventhub_resource_group_name")

  // Retrieve the name of the Event Hub namespace
  eventHubNamespaceName := terraform.Output(t, terraformOptions, "eventhub_namespace_name")

  // Check that the Event Hub namespace was created successfully
  azure.AssertEventHubNamespaceExists(t, eventHubResourceGroupName, eventHubNamespaceName)

  // Retrieve the name of the Event Hub topic
  eventHubTopicName := terraform.Output(t, terraformOptions, "eventhub_topic_name")

  // Assert that the AKS cluster name, resource group, and event hub name match the expected values
  assert.Equal(t, "test-aks-cluster", output["aks_cluster_name"])
  assert.Equal(t, "test-aks-rg", output["resource_group_name"])
  assert.Equal(t, "test-eventhub-namespace", output["eventhub_namespace_name"]) 
}
