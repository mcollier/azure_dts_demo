targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
@allowed(['westus2', 'eastus', 'eastus2'])
@metadata({
  azd: {
    type: 'location'
  }
})
param location string

@description('Name of the storage account.')
param storageAccountName string = ''  // if empty, will be auto-generated

param dtsSkuName string = 'Dedicated'
param dtsCapacity int = 1
param dtsName string = '' // if empty, will be auto-generated
param taskHubName string = '' // if empty, will be auto-generated

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }
var resourceToken = toLower(uniqueString(subscription().id, rg.id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01'={
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module dts './modules/dts.bicep'={
  scope: rg
  params:{
    name: !empty(dtsName) ? dtsName : '${abbrs.dts}${resourceToken}'
    taskHubName: !empty(taskHubName) ? taskHubName : '${abbrs.taskhub}${resourceToken}'
    location: location
    tags: tags
    ipAllowlist:[
      '0.0.0.0/0'  // TODO: tighten this up for production use
    ]
    skuCapacity: dtsCapacity
    skuName: dtsSkuName
  }
  dependsOn:[
    storage  // TODO: Need this dependency?
  ]
}

module storage './modules/storage.bicep'={
  scope: rg
  params:{
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    location: location
    tags: tags
  }
}



