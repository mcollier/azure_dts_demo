# Azure Infrastructure Setup

This directory contains the scripts and workflows needed to provision Azure resources for the Azure Durable Task Scheduler Demo.

## Setup Instructions

### Prerequisites

Before running the setup script, ensure you have the following tools installed:

1. **Azure CLI** - [Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **GitHub CLI** - [Installation Guide](https://cli.github.com/)

### Step 1: Authenticate with Azure and GitHub

```bash
# Login to Azure
az login

# Login to GitHub
gh auth login
```

### Step 2: Run the Setup Script

Navigate to the project root and run the Azure authentication setup script:

```bash
./scripts/setup-azure-auth.sh
```

This script will:
- Create an Azure service principal with OIDC federated identity
- Assign the necessary permissions (Contributor role at subscription level)
- Set up GitHub repository secrets for authentication

### Step 3: Verify Setup

After running the setup script, you should see the following secrets in your GitHub repository settings:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID` 
- `AZURE_SUBSCRIPTION_ID`

## GitHub Workflow

The infrastructure deployment workflow (`.github/workflows/deploy-infrastructure.yml`) provides:

### Automatic Triggers
- **Push to main branch**: Automatically deploys to the development environment
- **Pull Request**: Shows a preview of infrastructure changes without deploying
- **Manual Trigger**: Allows deployment to specific environments (dev/staging/prod)

### Features
- **Template Validation**: Validates Bicep templates before deployment
- **What-if Analysis**: Shows preview of changes on pull requests
- **Environment-specific Parameters**: Uses different parameter files for each environment
- **Deployment Summaries**: Provides detailed deployment information

### Environment Configuration

The workflow supports three environments with different parameter files:

- **Development** (`infra/main.dev.bicepparam`): Low-cost configuration for development
- **Staging** (`infra/main.staging.bicepparam`): Moderate configuration for testing
- **Production** (`infra/main.prod.bicepparam`): Production-ready configuration with zone redundancy

## Manual Deployment

You can also deploy the infrastructure manually using the Azure CLI:

```bash
# Navigate to the infra directory
cd infra

# Deploy using the existing script
./deploy.sh

# Or deploy directly with Azure CLI
az deployment sub create \
  --template-file main.bicep \
  --parameters main.dev.bicepparam \
  --location eastus2 \
  --name my-deployment
```

## Security Considerations

- The setup uses **OIDC federated identity** for secure authentication without storing long-lived secrets
- The service principal has **Contributor role** at the subscription level (required for resource group creation)
- All authentication is handled through Azure Active Directory with no client secrets stored in GitHub

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you have sufficient permissions in your Azure subscription
2. **GitHub Secrets Not Set**: Verify the GitHub CLI is authenticated and has repository access
3. **Deployment Failures**: Check the Azure portal for detailed error messages

### Support

For issues with the infrastructure deployment, check:
- Azure portal deployment history
- GitHub Actions workflow logs
- Azure resource group activity logs