#!/usr/bin/env bash
set -euo pipefail

APP_NAME="func-vu2qfc3ahlkm6"
FUNCTION_AZURE_STORAGE_ACCOUNT="stvu2qfc3ahlkm6"
FUNCTION_CONTAINER_NAME="app-package-func-vu2qfc3ahlkm6-vu2qfc3"
RESOURCE_GROUP="rg-azdts-demo-local"

# Use the Azure CLI to publish the Azure Function App

#  Build the Function App
dotnet publish --configuration Release

# Zip the function app source code
pushd src/bin/Release/net8.0

zip -r ../../../../functionapp.zip .

popd

# Upload the zip file to the Azure Function App
az functionapp deployment source config-zip \
    --src functionapp.zip \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP

# Use Azure Functions Core Tools to publish the Azure Function App
# func azure functionapp publish $APP_NAME