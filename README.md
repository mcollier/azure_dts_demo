# Azure Durable Task Scheduler Demo

> **⚠️ WARNING: WORK-IN-PROGRESS DEMO PROJECT ⚠️**
> 
> This is an experimental and exploratory project demonstrating Azure Durable Task Scheduler capabilities. This code is provided for educational and demonstration purposes only.
> **PROCEED AT YOUR OWN RISK** - This is not production-ready code.

## Overview

This repository contains a demonstration of [Azure Durable Task Scheduler](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/), a managed service for orchestrating durable, serverless task workflows in Azure. The demo includes:

- **Sample Azure Functions** (.NET 8.0) showcasing durable orchestrations, activities, and external events
- **Infrastructure as Code** using Azure Bicep templates for complete Azure resource provisioning
- **Security-first approach** with managed identity authentication and proper RBAC configurations
- **Monitoring integration** with Application Insights and Log Analytics

The demo implements a simple claim approval workflow that demonstrates core Durable Task Scheduler concepts including orchestration functions, activity functions, and external event handling.

## Azure Resources Provisioned

The Bicep templates in this repository will provision the following Azure resources:

| Resource Type | Purpose | SKU/Tier |
|---------------|---------|----------|
| **Durable Task Scheduler** | Managed service for orchestrating durable workflows | Dedicated tier |
| **Azure Functions App** | Hosts the durable function code (.NET 8.0 isolated) | Elastic Premium (EP1) |
| **App Service Plan** | Compute hosting plan for the Functions App | Elastic Premium, Linux |
| **Storage Account** | Function app storage, state management, and deployment artifacts | Standard, secure configuration |
| **Application Insights** | Application performance monitoring and telemetry | Standard |
| **Log Analytics Workspace** | Centralized logging and analytics | 30-day retention |
| **Resource Group** | Logical container for all resources | N/A |
| **RBAC Role Assignments** | Secure access using managed identities | Multiple built-in roles |

### Security Features

- **Managed Identity Authentication**: No connection strings or secrets stored in configuration
- **Role-Based Access Control**: Principle of least privilege with specific role assignments
- **Network Security**: Configurable IP allowlists and secure endpoints
- **TLS 1.2 Enforcement**: All communications use modern encryption standards

## Important Limitations

- **⚠️ Platform Support**: Durable Task Scheduler does not yet support Functions on Flex Consumption or Container Apps. See [Microsoft Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/develop-with-durable-task-scheduler-functions#limitations).
- **⚠️ Preview Service**: Azure Durable Task Scheduler is currently in preview and subject to change.

## Getting Started

1. **Prerequisites**: Azure subscription, Azure CLI, .NET 8.0 SDK
2. **Deploy Infrastructure**: Use the Bicep templates in the `infra/` directory
3. **Deploy Code**: Build and deploy the Functions App from the `src/` directory
4. **Test**: Use the provided HTTP endpoints to trigger orchestrations

For detailed setup instructions, refer to the deployment scripts and configuration files in this repository.