param location string = 'westeurope'
param environmentId string
param containerRegistry string
param containerRegistryUsername string
param imagePath string

@secure()
param registrySecretRefName string

resource cosmosdbapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'cosmosdbapp'
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: 'registry-key'
        }
      ]
      secrets: [
        {
          name: 'registry-key'
          value: registrySecretRefName
        }
      ]
      dapr: {
        enabled: true
        appPort: 80
        appId: 'cosmosdbapp'
      }
    }
    template: {
      containers: [
        {
          image: imagePath
          name: 'query'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}