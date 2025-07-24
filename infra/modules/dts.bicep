param name string
param location string
param taskHubName string
param skuName string
param skuCapacity int
param ipAllowlist array
param tags object = {}

resource dts 'Microsoft.DurableTask/schedulers@2025-04-01-preview'={
  location: location
  tags: tags
  name: name
  properties:  {
    ipAllowlist: ipAllowlist
    sku:{
      name: skuName
      capacity: skuCapacity
    }
  }

  resource taskHub 'taskHubs' = {
    name: taskHubName
  }

  resource retentionPolicy 'retentionPolicies' = {
    name: 'default'
    properties: {
      retentionPolicies: [
        {
          retentionPeriodInDays: defaultRetentionPeriod
        }
        {
          retentionPeriodInDays: completedRetentionPeriod
          orchestrationState: 'Completed'
        }
        {
          retentionPeriodInDays: failedRetentionPeriod
          orchestrationState: 'Failed'
        }
      ]
    }
  }
}

output dts_NAME string = dts.name
output dts_URL string = dts.properties.endpoint
output TASKHUB_NAME string = dts::taskHub.name
