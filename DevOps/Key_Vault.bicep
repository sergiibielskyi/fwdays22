param keyVaultName string = 'fwDaysKeyVaultDemo'
param location string = resourceGroup().location
param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false
param tenantId string = subscription().tenantId
param objectId string
param secretNameCosmosDB string = 'cosmosdb-masterKey'
param secretNameBlob string = 'blob-masterKey'

var cnf = json(loadTextContent('../config.json'))
var secretValueCosmosDB = cnf.secretValueCosmosDB
var secretValueBlob = cnf.secretValueBlob

param secretPermissions array = [
  'GET'
]


param skuName string = 'standard'


resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: secretPermissions
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource secretCosmosDB 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: secretNameCosmosDB
  properties: {
    value: secretValueCosmosDB
  }
}

resource secretBlob 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: secretNameBlob
  properties: {
    value: secretValueBlob
  }
}
