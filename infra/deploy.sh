#!/usr/bin/env bash
set -euo pipefail

# 1. Validate template (30 seconds)
# az deployment sub validate \
#   --template-file main.bicep \
#   --parameters main.bicepparam \
#   --location eastus2

# 2. Preview changes (1 minute)
# az deployment sub what-if \
#   --template-file main.bicep \
#   --parameters main.bicepparam \
#   --location eastus2


  az deployment sub create \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --parameters principalId=$(az ad signed-in-user show --query id -o tsv) \
  --location eastus2 \
  --name flexconsumption-test