# Azure Durable Task Scheduler Demo

:warning: This is an incomplete sample & exploratory project. Proceed with caution. :warning:

## Infrastructure Deployment

This project includes automated Azure infrastructure provisioning via GitHub Actions. 

### Quick Start

1. **Set up Azure authentication**: Run the setup script to configure GitHub secrets and Azure service principal
   ```bash
   ./scripts/setup-azure-auth.sh
   ```

2. **Deploy infrastructure**: Push changes to the `main` branch or manually trigger the workflow

See [Azure Setup Documentation](docs/azure-setup.md) for detailed instructions.

### Notes

- :( Durable Task Scheduler does not yet support Functions on Flex Consumption or Container Apps. See [here](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-task-scheduler/develop-with-durable-task-scheduler-functions#limitations).