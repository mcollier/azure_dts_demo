# Getting Started with Azure Durable Task Scheduler

## About me

**Michael S. Collier**

_Principal Architect, Centric Consulting_

- Blog: [http://michaelscollier.com](https://michaelscollier.com)
- Socials:
  - LinkedIn: [https://www.linkedin.com/in/mcollier/](https://www.linkedin.com/in/mcollier/)
  - BlueSky: [https://bsky.app/profile/michaelscollier.com](https://bsky.app/profile/michaelscollier.com)
  - Threads: [https://www.threads.com/@michaelcollier01](https://www.threads.com/@michaelcollier01)

## Durable Functions

- Durable Functions is an Azure Function feature.
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

- Securing access to Azure Storage (enabling proper RBAC and VNET)
- Storage account sprawl
- Observability
  - [Durable Functions Monitor (DFMon)](https://github.com/microsoft/DurableFunctionsMonitor)
  - DFMon limited to a single Storage Account (and related task hubs)
- Performance
  - Azure Storage alternatives: Netherite or MSSQL
- Purging old orchestration data

## :tada: Durable Task Scheduler (DTS)

Purpose-built Azure resource (Microsoft.DurableTask/scheduler) optimized for solutions built on Durable Task Framework.

![dts-architecture](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/media/durable-task-scheduler/architecture.png)

### :heartpulse: Benefits

- Separate service from the Durable Function app (isolation, scaling, support)
- Durable Task Scheduler dashboard :boom:
- Multiple task hubs (environment, team, etc.)
- Local emulator
- Autopurge
- Performance (5x Azure Storage)!

![benchmark](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/media/durable-task-scheduler/performance.png)

### :warning: Limitations

- Preview status
- Only supports Functions Premium (EP) and App Service :frowning_face:
- Limited regions
- Not yet feature parity

### :running_man: Run Locally

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
            "type": "azureManaged", // "AzureStorage" is non-DTS setting
            "connectionStringName": "DURABLE_TASK_SCHEDULER_CONNECTION_STRING"
          }
        }
      }
    }
    ```
1. local.settings.json
    ```json
    {
      "Values": {
        "DURABLE_TASK_SCHEDULER_CONNECTION_STRING":"Endpoint=http://localhost:8080;Authentication=Non",
        "TASKHUB_NAME": "default"
      }
    }
    ```
1. Local emulator
    ```
    docker pull mcr.microsoft.com/dts/dts-emulator:latest
    ```

#### :zap: DEMO TIME :zap:

1. Start emulator
    ```
    docker run --name dts-emulator -d -p 8080:8080 -p 8082:8082 mcr.microsoft.com/dts/dts-emulator:latest
    ```
2. View the logs
    ```
    docker logs -f dts-emulator
    ```
3. Browse to dashboard at http://localhost:8082/
4. Start Azurite
5. Start DF - `func start`
6. Run orchestration using [test.http](../src/test.http) file
7. Send external event - ClaimApproval
    ```json
    {
      "Approved": true,
      "Reason": "Because this is awesome!"
    }
    ```

### :cloud_with_lightning: Azure

1. Provision a DTS resource - Azure portal, Azure CLI, Bicep, etc.
2. Set up RBAC permissions - Durable Task Data Coordinator
   1. Yourself (if necessary)
   2. Identity of the function app
3. Application settings - `DURABLE_TASK_SCHEDULER_CONNECTION_STRING` and `TASKHUB_NAME`
4. Deploy as normal

## :dollar: Pricing

Based on Capacity Unit (CU):
- Single tenant with dedicated resources
- Up to 2,000 work items dispatched per second
- 50 GB of orchestration data storage
- **$615.001/month**