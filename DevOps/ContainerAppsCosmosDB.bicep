param cosmosDBimagePath string = 'fwdays.azurecr.io/query:latest'
param resourceGroupName string = 'fwdays22'
param cosmosdbUrl string = 'https://fwdaysaccount.documents.azure.com:443/'
param location string = 'westeurope'
param environmentName string = 'fwdays-env'
param environmentId string = '/subscriptions/893b6379-78b0-4aea-a12e-5e74dcd1f506/resourceGroups/fwdays22/providers/Microsoft.App/managedenvironments/fwdays-env'
param collectionName string = 'fwDaysContainer'
param cosmosDBName string = 'fwDaysDB'
param containerRegistry string = 'fwdays.azurecr.io'


var cnf = json(loadTextContent('../config.json'))
var containerAdmin = cnf.containerAdmin
var containerKey = cnf.containerKey
var cosmosKey = cnf.secretValueCosmosDB

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
  name: '${environmentName}/cosmosdbapp'
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


