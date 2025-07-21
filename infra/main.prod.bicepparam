using 'main.bicep'

// Production environment parameters
param location = 'eastus2'
param dtsCapacity = 4
param dtsSkuName = 'Dedicated'
param environmentName = 'azdts-demo-prod'

// Production-ready configuration
param zoneRedundant = true