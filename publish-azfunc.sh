#!/usr/bin/env bash
set -euo pipefail

# Replace "YOUR_AZURE_FUNCTION_APP_NAME" with the name of your Azure Function App.
APP_NAME="YOUR_AZURE_FUNCTION_APP_NAME"

# Replace "YOUR_AZURE_RESOURCE_GROUP_NAME" with the name of your Azure Resource Group.
RESOURCE_GROUP="YOUR_AZURE_RESOURCE_GROUP_NAME"

#  Build the Function App
dotnet publish --configuration Release

# Zip the function app source code
DOTNET_VERSION="net8.0"
BUILD_PATH="src/bin/Release/$DOTNET_VERSION"

if [ ! -d "$BUILD_PATH" ]; then
    echo "Error: Build path '$BUILD_PATH' does not exist."
    exit 1
fi

pushd "$BUILD_PATH"
zip -r ../../../../functionapp.zip .

popd

# Use the Azure CLI to publish the Azure Function App
# Upload the zip file to the Azure Function App
az functionapp deployment source config-zip \
    --src functionapp.zip \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP"

# Use Azure Functions Core Tools to publish the Azure Function App
# func azure functionapp publish "$APP_NAME"