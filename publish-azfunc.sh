#!/usr/bin/env bash
set -euo pipefail

APP_NAME="YOUR_AZURE_FUNCTION_APP_NAME"
RESOURCE_GROUP="YOUR_AZURE_RESOURCE_GROUP_NAME"

#  Build the Function App
dotnet publish --configuration Release

# Zip the function app source code
pushd src/bin/Release/net8.0

zip -r ../../../../functionapp.zip .

popd

# Use the Azure CLI to publish the Azure Function App
# Upload the zip file to the Azure Function App
az functionapp deployment source config-zip \
    --src functionapp.zip \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP

# Use Azure Functions Core Tools to publish the Azure Function App
# func azure functionapp publish $APP_NAME