@minLength(3)
@maxLength(24)
@description('Provide a name for the storage account. Use only lower case letters and numbers. The name must be unique across Azure.')
param storageAccountName string

@description('Please enter a storage type')
@allowed([
  'Standard_ZRS'
  'Standard_LRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param storageType string

@description('Please enter a project tag')
@allowed(
  [
    'Core Infrastructure'
    'Draper and Dash'
    'OpenEHR'
  ]
)
param projectTag string

@description('Please enter an owner tag')
@allowed(
  [
    'Unknown'
    'Desktop Services'
    'DIA'
    'Technical Services Team'
  ]
)
param ownerTag string

@description('Please enter an environment tag')
@allowed(
  [
    'Production'
    'Development'
    'Test'
  ]
)
param environmentTag string

param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
    location: location
    kind: 'StorageV2'
    name: storageAccountName
    sku: {
      name: storageType
    }
    properties: {

      minimumTlsVersion: 'TLS1_2'
      allowBlobPublicAccess: false
      allowSharedKeyAccess: true
      supportsHttpsTrafficOnly: true
      encryption: { 
        services: {
          file: { 
            enabled: true
          }
          blob: {
            enabled: true
          }
        }
        keySource: 'Microsoft.Storage'
      }
      accessTier: 'Hot'
      }
      tags: {
        Environment: environmentTag
        Owner: ownerTag
        Project: projectTag
      }
}
