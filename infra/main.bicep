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

param logAnalyticsName string = '' // if empty, will be auto-generated
param applicationInsightsName string = '' // if empty, will be auto-generated
param functionPlanName string = '' // if empty, will be auto-generated
param functionAppName string = '' // if empty, will be auto-generated
param zoneRedundant bool = false

@minValue(40)
@maxValue(1000)
param maximumInstanceCount int = 100

@allowed([512,2048,4096])
param instanceMemoryMB int = 2048

@allowed(['dotnet-isolated','python','java', 'node', 'powerShell'])
param functionAppRuntime string = 'dotnet-isolated'

@allowed(['3.10','3.11', '3.12', '7.4', '8.0', '9.0', '10', '11', '17', '20', '21', '22'])
param functionAppRuntimeVersion string = '8.0'

@description('Id of the user running this template, to be used for testing and debugging for access to Azure resources. This is not required in production. Leave empty if not needed.')
param principalId string = ''


var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }
var resourceToken = toLower(uniqueString(subscription().id, rg.id, environmentName, location))

// Generate a unique function app name if one is not provided.
var functionAppName_resolved = !empty(functionAppName) ? functionAppName : '${abbrs.webSitesFunctions}${resourceToken}'

// Generate a unique container name that will be used for deployments.
var deploymentStorageContainerName = 'app-package-${take(functionAppName_resolved, 32)}-${take(resourceToken, 7)}'



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

// module storage './modules/storage.bicep'={
//   scope: rg
//   params:{
//     name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
//     location: location
//     tags: tags
//   }
// }

module storage 'br/public:avm/res/storage/storage-account:0.25.0' = {
  name: 'storage'
  scope: rg
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false // Disable local authentication methods as per policy
    dnsEndpointType: 'Standard'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    blobServices: {
      containers: [{name: deploymentStorageContainerName}]
    }
    tableServices:{}
    queueServices: {}
    minimumTlsVersion: 'TLS1_2'  // Enforcing TLS 1.2 for better security
    location: location
    tags: tags
  }
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.11.1' = {
  name: '${uniqueString(deployment().name, location)}-loganalytics'
  scope: rg
  params: {
    name: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
    tags: tags
    dataRetention: 30
  }
}

module applicationInsights 'br/public:avm/res/insights/component:0.6.0' = {
  name: '${uniqueString(deployment().name, location)}-appinsights'
  scope: rg
  params: {
    name: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
    disableLocalAuth: true
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(functionPlanName) ? functionPlanName : '${abbrs.webServerFarms}${resourceToken}'
    sku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    reserved: true
    location: location
    tags: tags
    zoneRedundant: zoneRedundant
  }
}

// Azure Functions Flex Consumption
module functionApp 'br/public:avm/res/web/site:0.16.0' = {
  name: 'functionapp'
  scope: rg
  params: {
    kind: 'functionapp,linux'
    name: functionAppName_resolved
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })
    serverFarmResourceId: appServicePlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.outputs.primaryBlobEndpoint}${deploymentStorageContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      runtime: { 
        name: functionAppRuntime
        version: functionAppRuntimeVersion
      }
    }
    siteConfig: {
      alwaysOn: false
    }
    configs: [{
      name: 'appsettings'
      properties:{
        // Only include required credential settings unconditionally
        AzureWebJobsStorage__credential: 'managedidentity'
        AzureWebJobsStorage__blobServiceUri: 'https://${storage.outputs.name}.blob.${environment().suffixes.storage}'
        AzureWebJobsStorage__queueServiceUri: 'https://${storage.outputs.name}.queue.${environment().suffixes.storage}'
        AzureWebJobsStorage__tableServiceUri: 'https://${storage.outputs.name}.table.${environment().suffixes.storage}'

        // Application Insights settings are always included
        APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.outputs.connectionString
        APPLICATIONINSIGHTS_AUTHENTICATION_STRING: 'Authorization=AAD'
    }
    }]
  }
}

// Consolidated Role Assignments
module rbacAssignments 'rbac.bicep' = {
  name: 'rbacAssignments'
  scope: rg
  params: {
    storageAccountName: storage.outputs.name
    appInsightsName: applicationInsights.outputs.name
    managedIdentityPrincipalId: functionApp.outputs.?systemAssignedMIPrincipalId ?? ''
    userIdentityPrincipalId: principalId
    allowUserIdentityPrincipal: !empty(principalId)
  }
}
