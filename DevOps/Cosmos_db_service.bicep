param accountName string = 'fwDaysAccount'
param location string = resourceGroup().location
param primaryRegion string = resourceGroup().location
param defaultConsistencyLevel string = 'Session'
param databaseName string = 'fwDaysDB'
param containerName string = 'fwDaysContainer'
param autoscaleMaxThroughput int = 4000
param maxStalenessPrefix int = 100
param maxIntervalInSeconds int = 5

var accountName_var = toLower(accountName)
var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}
var locations = [
  {
    locationName: primaryRegion
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' = {
  name: accountName_var
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
  }
}

resource accountName_databaseName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-01-15' = {
  parent: accountName_resource
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource accountName_databaseName_containerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-01-15' = {
  parent: accountName_databaseName
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: autoscaleMaxThroughput
      }
    }
  }
}

output cosmosdb_url string = accountName_resource.properties.documentEndpoint
output database_name string = databaseName
output collection_name string = containerName
output primaryMasterKey string = listKeys(accountName_resource.id, accountName_resource.apiVersion).primaryMasterKey
