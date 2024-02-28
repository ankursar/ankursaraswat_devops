# Minikube Environment Setup with Terraform

This repository contains Terraform configurations to provision a Minikube environment and deploy a web application. The repository is structured into two main directories:

1. **app**: This directory contains the application deployment configuration files:

   - Dockerfile: Dockerfile for building the application container.
   - Source code: Source code files for the web application.
   - Helm chart: Helm chart for deploying the application onto Kubernetes.

2. **infra**: This directory contains Terraform Infrastructure as Code (IAC) configurations for setting up the infrastructure:

   - Terraform configuration files: Files to provision the infrastructure, such as VMs and Minikube setup.

## Application Build

To build the container image for the web application, use the following command:

```bash
docker build -t webapp:v1 .
```

## Infra Setup

To deploy VMs on Azure Cloud using Terraform, follow these steps:

1. Update the necessary parameters in the `provider.tf` file located in the `infra` directory:

   ```hcl
   provider "azurerm" {
     features {}
     subscription_id = "your-subscription-id"
     client_id       = "your-client-id"
     client_secret   = "your-client-secret"
     tenant_id       = "your-tenant-id"
   }
   ```

2. Run Terraform commands to apply the configuration and provision the infrastructure.

## Webapp Deployment on Minikube Cluster

To deploy the web application on the Minikube cluster, follow these steps:

1. Navigate to the `app` directory:

   ```bash
   cd app
   ```

2. Update the values in the `values.yaml` file as needed.

3. Deploy the web application using Helm:

   ```bash
   helm install webapp ./webapp --namespace webapp
   ```

## Accessing the Web Application

The web application is accessible at [http://webapp.example.com](http://webapp.example.com). However, since Minikube is set up, you cannot access this URL through a VM public IP. Please update `<minikube ip>` with your Minikube IP address in the `/etc/hosts` file of VM.

For any issues or questions, please feel free to open an issue or reach out to the maintainer.# ankursaraswat_devops
