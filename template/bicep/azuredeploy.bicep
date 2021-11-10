param storageSelector string
var location = resourceGroup().location
var prefix = 'pv'
var randomString = substring(guid(resourceGroup().id),0,6)

// Azure Storage Account
resource adls 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${prefix}${randomString}adls'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: true
  }
}

output myOut string = storageSelector
