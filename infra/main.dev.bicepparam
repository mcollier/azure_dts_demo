using 'main.bicep'

// Development environment parameters
param location = 'eastus2'
param dtsCapacity = 1
param dtsSkuName = 'Dedicated'
param environmentName = 'azdts-demo-dev'

// Use lower-cost options for development
param zoneRedundant = false