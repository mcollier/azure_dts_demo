#!/usr/bin/env bash
set -euo pipefail

VALIDATE=false
PREVIEW=false

# 1. Validate template (30 seconds)
if [ "$VALIDATE" = true ]; then
    echo "Validating template..."

    az deployment sub validate \
      --template-file main.bicep \
      --parameters main.bicepparam \
      --location eastus2
fi

# 2. Preview changes (1 minute)
if [ "$PREVIEW" = true ]; then
    echo "Previewing changes..."
    
    az deployment sub what-if \
      --template-file main.bicep \
      --parameters main.bicepparam \
      --location eastus2
fi

az deployment sub create \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --parameters principalId=$(az ad signed-in-user show --query id -o tsv) \
  --location eastus2 \
  --name flexconsumption-test