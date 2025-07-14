param name string
param location string = resourceGroup().location
param tags object = {}

resource storage 'Microsoft.Storage/storageAccounts@2025-01-01'={
  name: name
  location: location
  tags: tags
  sku:{
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    networkAcls:{
      bypass: 'AzureServices'
      defaultAction: 'Allow' // TODO: tighten this up for production use
    }
  }
}
