param keyVaultName string = 'fwDaysKeyVaultDemo'
param location string = resourceGroup().location
param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false
param tenantId string = subscription().tenantId
param objectId string
param secretName string = 'cosmosdb-masterKey'

var cnf = json(loadTextContent('../config.json'))
var secretValue = cnf.secretValue

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

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: secretName
  properties: {
    value: secretValue
  }
}
