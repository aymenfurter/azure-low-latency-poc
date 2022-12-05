# azure-low-latency-poc
This project is for deploying an Azure Kubernetes Service (AKS) cluster and an Azure Event Hub. The AKS cluster will be used for deploying and managing containerized applications, while the Event Hub will be used for data streaming and ingestion. The project includes a Terraform configuration for provisioning the AKS cluster and Event Hub, as well as a Terraform variable file for defining customizable parameters. Additionally, a Terraform test file is included for validating the deployment. 

## Local Setup
To use this infrastructure project, follow the steps below:

1. Clone the repository to your local machine using git clone https://github.com/[USERNAME]/[REPO_NAME].git.
2. Navigate to the cloned repository using cd [REPO_NAME].
3. Install the required dependencies using terraform init.
4. Create a terraform.tfvars file and define the required input variables. A sample terraform.tfvars.example file is provided for reference.
5. Run terraform plan to see the infrastructure that will be created.
6. Run terraform apply to create the infrastructure.
7. Once the infrastructure has been created, run terraform destroy to tear down the infrastructure.
8. Additionally, the repository contains a test directory containing integration tests for the infrastructure using Terratest. To run these tests, follow the steps below:

Install Go on your local machine.
1. Navigate to the test directory using cd test.
2. Install the required dependencies using go mod download.
3. Run go test -v to run the tests.
4. Please note that running the tests will create and destroy real resources in your Azure subscription, and may incur charges.