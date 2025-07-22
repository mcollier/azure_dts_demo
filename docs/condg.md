# Central Ohio .NET Developer User Group

## About me

ADD BIO HERE

- Blog: [http://michaelscollier.com](https://michaelscollier.com)
- Socials:
  - LinkedIn:
    - QR
  - BlueSky:
  - Threads:

## Durable Functions

- Durable Functions is Azure Function feature.
  - Stateful workflows via "orchestrator functions".
  - Stateful entities via "entity functions".
- Durable Functions manages state, checkpoints, etc.
- Heavily leverages Azure Storage (tables and queues).
- Durable Task Framework
- Supported languages:
  - NET
  - JavaScript
  - Python
  - PowerShell
  - Java

### Patterns

#### Function Chaining
![alt text](https://learn.microsoft.com/en-us/azure/azure-functions/durable/media/durable-functions-concepts/function-chaining.png)

#### Fan-out/fan-in

![fanout-fanin](https://learn.microsoft.com/en-us/azure/azure-functions/durable/media/durable-functions-concepts/fan-out-fan-in.png)

#### Async HTTP APIs

![async http](https://learn.microsoft.com/en-us/azure/azure-functions/durable/media/durable-functions-concepts/async-http-api.png)

#### Monitor
![Monitor](https://learn.microsoft.com/en-us/azure/azure-functions/durable/media/durable-functions-concepts/monitor.png)

#### Human interaction
![Human interaction](https://learn.microsoft.com/en-us/azure/azure-functions/durable/media/durable-functions-concepts/approval.png)

### :ghost: Challenges

- Securing access to Azure Storage (enabling proper RBAC)
- Storage account sprawl
- Observability
  - [Durable Functions Monitor](https://github.com/microsoft/DurableFunctionsMonitor)
  - DFMon limited to a single Storage Account (and related task hubs)
- Performance
  - Azure Storage alternatives: Netherite or MSSQL
- Clearing old orchestration data

## :tada: Durable Task Scheduler (DTS)

Purpose-built Azure resource (Microsoft.DurableTask/scheduler) optimized for solutions built on Durable Task Framework.

![dts-architecture](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/media/durable-task-scheduler/architecture.png)

### :heartpulse: Benefits

- Separate service from the Durable Function app (isolation, scaling, support)
- Durable Task Scheduler dashboard :boom:
- Multiple task hubs (environment, team, etc.)
- Local emulator
- Autopurge

### :warning: Limitations

- Preview status
- Only supports Functions Premium (EP) and App Service :frowning_face:
- Limited regions
- Not yet feature parity

### Run Locally

Assuming an existing Durable Function:
1. Add DTS package
    ```
    dotnet add package Microsoft.Azure.Functions.Worker.Extensions.DurableTask.AzureManaged --prerelease
    ```
1. host.json
    ``` json
    {
      "extensions": {
        "durableTask": {
          "hubName": "%TASKHUB_NAME%",
          "storageProvider": {
            "type": "azureManaged",
            "connectionStringName": "DURABLE_TASK_SCHEDULER_CONNECTION_STRING"
          }
        }
      }
    }
    ```
1. local.settings.json
    ```json
    {
      "Values:{
        "DURABLE_TASK_SCHEDULER_CONNECTION_STRING":"",
        "TASKHUB_NAME": ""
      }
    }
    ```
1. Local emulator
    ```
    docker pull mcr.microsoft.com/dts/dts-emulator:latest
    ```

DEMO TIME

1. Start emulator
2. Browse to dashboard at http://localhost:8082/
3. Run orchestration using test.http file

### Azure

