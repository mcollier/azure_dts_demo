#!/usr/bin/env bash
set -euo pipefail

# Script to set up Azure service principal for GitHub Actions with OIDC federated identity
# This script creates a service principal with the necessary permissions for deploying
# the Azure DTS Demo infrastructure via GitHub Actions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
APP_NAME="github-actions-azure-dts-demo"
GITHUB_OWNER=""
GITHUB_REPO=""
GITHUB_BRANCH="main"

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_message $BLUE "Checking prerequisites..."
    
    if ! command -v az &> /dev/null; then
        print_message $RED "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        print_message $RED "GitHub CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        print_message $RED "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if logged into GitHub
    if ! gh auth status &> /dev/null; then
        print_message $RED "Not logged into GitHub. Please run 'gh auth login' first."
        exit 1
    fi
    
    print_message $GREEN "Prerequisites check passed."
}

# Function to get GitHub repository information
get_github_info() {
    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO" ]; then
        print_message $BLUE "Detecting GitHub repository information..."
        
        # Try to get from git remote
        if git remote get-url origin &> /dev/null; then
            local remote_url=$(git remote get-url origin)
            if [[ $remote_url =~ github\.com[/:]([^/]+)/([^/\.]+) ]]; then
                GITHUB_OWNER="${BASH_REMATCH[1]}"
                GITHUB_REPO="${BASH_REMATCH[2]}"
            fi
        fi
        
        # If still not found, ask user
        if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO" ]; then
            print_message $YELLOW "Please provide GitHub repository information:"
            read -p "GitHub Owner/Organization: " GITHUB_OWNER
            read -p "GitHub Repository Name: " GITHUB_REPO
        fi
    fi
    
    print_message $GREEN "GitHub Repository: $GITHUB_OWNER/$GITHUB_REPO"
}

# Function to create or get service principal
setup_service_principal() {
    print_message $BLUE "Setting up Azure service principal..."
    
    local subscription_id=$(az account show --query id -o tsv)
    local tenant_id=$(az account show --query tenantId -o tsv)
    
    print_message $BLUE "Subscription ID: $subscription_id"
    print_message $BLUE "Tenant ID: $tenant_id"
    
    # Check if service principal already exists
    local app_id=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
    
    if [ -z "$app_id" ] || [ "$app_id" == "null" ]; then
        print_message $YELLOW "Creating new service principal..."
        app_id=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
        az ad sp create --id "$app_id" > /dev/null
    else
        print_message $YELLOW "Using existing service principal..."
    fi
    
    print_message $GREEN "Service Principal App ID: $app_id"
    
    # Assign Contributor role at subscription level (required for resource group creation)
    print_message $BLUE "Assigning Contributor role to service principal..."
    az role assignment create \
        --assignee "$app_id" \
        --role "Contributor" \
        --scope "/subscriptions/$subscription_id" \
        --only-show-errors > /dev/null || true
    
    # Set up federated identity credential for GitHub Actions
    print_message $BLUE "Setting up federated identity credential..."
    local credential_name="github-actions-${GITHUB_REPO}"
    local subject="repo:${GITHUB_OWNER}/${GITHUB_REPO}:ref:refs/heads/${GITHUB_BRANCH}"
    
    # Check if credential already exists
    local existing_credential=$(az ad app federated-credential list --id "$app_id" --query "[?name=='$credential_name']" -o tsv)
    
    if [ -z "$existing_credential" ]; then
        az ad app federated-credential create \
            --id "$app_id" \
            --parameters "{
                \"name\": \"$credential_name\",
                \"issuer\": \"https://token.actions.githubusercontent.com\",
                \"subject\": \"$subject\",
                \"audiences\": [\"api://AzureADTokenExchange\"]
            }" > /dev/null
        print_message $GREEN "Federated identity credential created."
    else
        print_message $YELLOW "Federated identity credential already exists."
    fi
    
    # Export variables for GitHub secrets
    export AZURE_CLIENT_ID="$app_id"
    export AZURE_TENANT_ID="$tenant_id"
    export AZURE_SUBSCRIPTION_ID="$subscription_id"
}

# Function to set GitHub secrets
set_github_secrets() {
    print_message $BLUE "Setting GitHub repository secrets..."
    
    # Set the secrets
    echo "$AZURE_CLIENT_ID" | gh secret set AZURE_CLIENT_ID --repo "$GITHUB_OWNER/$GITHUB_REPO"
    echo "$AZURE_TENANT_ID" | gh secret set AZURE_TENANT_ID --repo "$GITHUB_OWNER/$GITHUB_REPO"
    echo "$AZURE_SUBSCRIPTION_ID" | gh secret set AZURE_SUBSCRIPTION_ID --repo "$GITHUB_OWNER/$GITHUB_REPO"
    
    print_message $GREEN "GitHub secrets have been set:"
    print_message $GREEN "  - AZURE_CLIENT_ID"
    print_message $GREEN "  - AZURE_TENANT_ID"
    print_message $GREEN "  - AZURE_SUBSCRIPTION_ID"
}

# Function to display summary
display_summary() {
    print_message $GREEN "\n=== Setup Complete ==="
    print_message $BLUE "Service Principal Details:"
    print_message $BLUE "  App Name: $APP_NAME"
    print_message $BLUE "  Client ID: $AZURE_CLIENT_ID"
    print_message $BLUE "  Tenant ID: $AZURE_TENANT_ID"
    print_message $BLUE "  Subscription ID: $AZURE_SUBSCRIPTION_ID"
    print_message $BLUE "\nGitHub Repository: $GITHUB_OWNER/$GITHUB_REPO"
    print_message $BLUE "Branch: $GITHUB_BRANCH"
    print_message $GREEN "\nYour GitHub Actions workflow can now authenticate to Azure using OIDC!"
    print_message $YELLOW "Note: The service principal has Contributor role at the subscription level."
}

# Main execution
main() {
    print_message $GREEN "=== Azure Service Principal Setup for GitHub Actions ==="
    print_message $BLUE "This script will:"
    print_message $BLUE "  1. Create an Azure service principal with OIDC federated identity"
    print_message $BLUE "  2. Assign necessary permissions for infrastructure deployment"
    print_message $BLUE "  3. Set up GitHub repository secrets"
    print_message $BLUE ""
    
    check_prerequisites
    get_github_info
    setup_service_principal
    set_github_secrets
    display_summary
}

# Run main function
main "$@"