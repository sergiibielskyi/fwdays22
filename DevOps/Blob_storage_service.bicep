param storageAccountName string
param containerName string
param location string = resourceGroup().location

resource blobStorage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  dependsOn: [
    // we need to ensure we wait for the resource group
    resourceGroup()
  ]
  properties: {
    accessTier: 'Cool'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${blobStorage.name}/default/${containerName}'
  dependsOn: [
    // we need to ensure we wait for the storage account
    blobStorage
  ]
}

output container_name string = container.name
output account_key string = blobStorage.listKeys().keys[0].value











