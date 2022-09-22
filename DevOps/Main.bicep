param cosmosDBimagePath string = 'martapp.azurecr.io/query:latest'
param resourceGroupName string = 'fwdays22'
param cosmosdbUrl string = 'https://fwdaysaccount.documents.azure.com:443/'
param location string = 'westeurope'
param environmentName string = 'fwdays-env'
param environmentId string = '/subscriptions/edb3ed55-b7ed-423c-bf55-6c6ba95cc54f/resourceGroups/fwdays22/providers/Microsoft.App/managedenvironments/fwdays-env'
param collectionName string = 'fwDaysContainer'
param cosmosDBName string = 'fwDaysDB'
param containerRegistry string = 'martapp.azurecr.io'


var cnf = json(loadTextContent('../config.json'))
var containerAdmin = cnf.containerAdmin
var containerKey = cnf.containerKey
var cosmosKey = cnf.secretValue

//Create Dapr CosmosDB State Management
module cosmosdbapp 'Cosmosdb.bicep' = {
  name: 'cosmosdbapp'
  params: {
    environmentId: environmentId
    location: location
    containerRegistry: containerRegistry
    containerRegistryUsername: containerAdmin
    registrySecretRefName: containerKey
    imagePath: cosmosDBimagePath
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup(resourceGroupName)
  ]
}

resource cosmosDBComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: '${environmentName}/cosmosdb'
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    secrets: [
      {
        name: 'cosmos-key'
        value: cosmosKey
      }
    ]
    metadata: [
      {
        name: 'url'
        value: cosmosdbUrl
      }
      {
        name: 'database'
        value: cosmosDBName
      }
      {
        name: 'collection'
        value: collectionName
      }
      {
        name: 'masterkey'
        secretRef: 'cosmos-key'
      }
    ]
    scopes: [
      cosmosdbapp.name
    ]
  }
}

// Create Dapr Blob State Management
/*module blobqueue 'Blob.bicep' = {
  name: 'blobqueue'
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

resource blobComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: '${environmentName}/blobqueue'
  properties: {
    componentType: 'bindings.azure.storagequeues'
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
        name: 'queue'
        value: 'objects'
      }
      {
        name: 'ttlInSeconds'
        value: '60'
      }
      {
        name: 'decodeBase64'
        value: 'false'
      }
    ]
    scopes: [
      blobqueue.name
    ]
  }
}*/


