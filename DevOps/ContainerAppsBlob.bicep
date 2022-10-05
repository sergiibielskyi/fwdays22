param blobImagePath string = 'fwdays.azurecr.io/request:latest'
param resourceGroupName string = 'fwdays22'
param location string = 'westeurope'
param environmentName string = 'fwdays-env'
param environmentId string = '/subscriptions/893b6379-78b0-4aea-a12e-5e74dcd1f506/resourceGroups/fwdays22/providers/Microsoft.App/managedenvironments/fwdays-env'
param accountName string = 'fwdaysdemostorage'
param containerRegistry string = 'fwdays.azurecr.io'


var cnf = json(loadTextContent('../config.json'))
var containerAdmin = cnf.containerAdmin
var containerKey = cnf.containerKey
var accountKey = cnf.secretValueBlob


// Create Dapr Blob State Management
module uploadblobapp 'Blob.bicep' = {
  name: 'uploadblobapp'
  params: {
    environmentId: environmentId
    location: location
    containerRegistry: containerRegistry
    containerRegistryUsername: containerAdmin
    registrySecretRefName: containerKey
    imagePath: blobImagePath
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup(resourceGroupName)
  ]
}

resource blobComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: '${environmentName}/uploadblobapp'
  properties: {
    componentType: 'bindings.azure.blobstorage'
    version: 'v1'
    secrets: [
      {
        name: 'account-key'
        value: accountKey
      }
    ]
    metadata: [
      {
        name: 'storageAccount'
        value: accountName
      }
      {
        name: 'storageAccessKey'
        secretRef: 'account-key'
      }
      {
        name: 'container'
        value: 'objects'
      }
      {
        name: 'decodeBase64'
        value: 'true'
      }
    ]
    scopes: [
      uploadblobapp.name
    ]
  }
}


