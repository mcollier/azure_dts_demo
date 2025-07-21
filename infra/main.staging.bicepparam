using 'main.bicep'

// Staging environment parameters
param location = 'eastus2'
param dtsCapacity = 2
param dtsSkuName = 'Dedicated'
param environmentName = 'azdts-demo-staging'

// Moderate configuration for staging
param zoneRedundant = false