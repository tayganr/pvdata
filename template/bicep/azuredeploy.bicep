param purviewAccountName string
param purviewResourceGroup string
param uniqueFileNameSuffix string

// Variables
var resourceGroupName = resourceGroup().name
var location = resourceGroup().location
var prefix = 'pvdq'
var randomString = substring(guid(resourceGroup().id),0,6)
var roleDefinitionprefix = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions'
var role = {
  Owner: '${roleDefinitionprefix}/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: '${roleDefinitionprefix}/b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: '${roleDefinitionprefix}/acdd72a7-3385-48ef-bd42-f606fba81ae7'
  UserAccessAdministrator: '${roleDefinitionprefix}/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  StorageBlobDataOwner: '${roleDefinitionprefix}/b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  StorageBlobDataContributor: '${roleDefinitionprefix}/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  StorageBlobDataReader: '${roleDefinitionprefix}/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

// Azure Purview Account
resource pv 'Microsoft.Purview/accounts@2021-07-01' existing = {
  name: purviewAccountName
  scope: resourceGroup(purviewResourceGroup)
}

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
  resource blobService 'blobServices' existing = {
    name: 'default'
    resource blobContainer 'containers' = {
      name: 'data'
    }
  }
}

// User Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'configDeployer'
  location: location
}

// Assign Storage Blob Data Reader RBAC role to Azure Purview MI
resource roleAssignment01 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('01${resourceGroupName}')
  scope: adls
  properties: {
    principalId: pv.identity.principalId
    roleDefinitionId: role['StorageBlobDataReader']
    principalType: 'ServicePrincipal'
  }
}

// Assign Storage Blob Data Contributor RBAC role to User Assigned Identity (configDeployer)
resource roleAssignment02 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('02${resourceGroupName}')
  scope: resourceGroup()
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: role['Contributor']
    principalType: 'ServicePrincipal'
  }
}

// Post Deployment Script (Load Data)
resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'postDeploymentScript'
  kind: 'AzurePowerShell'
  location: location
  properties: {
    azPowerShellVersion: '3.0'
    arguments: '-resource_group ${resourceGroupName} -storage_account_name ${adls.name} -filename_suffix ${uniqueFileNameSuffix}'
    primaryScriptUri: 'https://raw.githubusercontent.com/tayganr/purviewdq/main/script/postDeploymentScript.ps1'
    forceUpdateTag: guid(resourceGroup().id)
    retentionInterval: 'PT4H'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  dependsOn: [
    adls
    userAssignedIdentity
    roleAssignment02
  ]
}
