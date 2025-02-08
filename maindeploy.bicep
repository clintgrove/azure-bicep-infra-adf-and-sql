//param uniqueSuffix string = substring(uniqueString(resourceGroup().id),0,6)

@description('ADX Database Name')
param resourcelocation string = resourceGroup().location

@description('Which deployment environment DEV, TEST PROD etc')
param deploymentEnvironment string = 'dev'

@description('is this in test, dev or prod')

param gitConfigureLater bool = false
param gitRepoType string = 'FactoryGitHubConfiguration'
param gitAccountName string = 'clintgrove'
param gitRepositoryName string = 'azure-bicep-infra-adf-and-sql'
param gitCollaborationBranch string = 'main'
param gitRootFolder string = '/adf-dev'
param gitProjectName string = ''
@secure()
param serverPassword string

// Deploy Factory (note that if you deploy this data factory infrastructure with global parameters and you don't have the same global parameters in your /adf-dev git folder (see the folder structure)
// then when you do a build, which builds from the dev factory, then the global parameter, in this case infraGParam will disappear as it doesn't exist in your dev factory git folder /adf-dev )
// the best way to develop global parameters, managed private endpoints, datasets, linked services etc is to develop them in the factory and when you click save it will go go /adf-dev in the git repo
module factory 'br/public:avm/res/data-factory/factory:0.3.2' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-adfdeploy-dffmin'
  params: {
    name: 'adf-bicep-${deploymentEnvironment}-cgr2'
    location: resourcelocation
    gitConfigureLater : gitConfigureLater
    gitRepoType : bool(gitConfigureLater) ? null : gitRepoType
    gitAccountName : bool(gitConfigureLater) ? null : gitAccountName 
    gitRepositoryName : bool(gitConfigureLater) ? null : gitRepositoryName
    gitCollaborationBranch : bool(gitConfigureLater) ? null : gitCollaborationBranch
    gitRootFolder : bool(gitConfigureLater) ? null : gitRootFolder
    gitProjectName: bool(gitConfigureLater) ? null : gitProjectName
    globalParameters: {
      whichEnv: {
        type: 'String'
        value: deploymentEnvironment
      }
      infraGParam: {
        type: 'String'
        value: 'infravaluehere'
      }
    }
    managedIdentities: {
      systemAssigned: true
    }
    managedVirtualNetworkName: 'default'
  }
}

// The below is an example of building a pipeline in infra code instead of building a pipeline in the git repo (which will be attached to the factory using lines 29 - 35)
resource m_DataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'adf-bicep-${deploymentEnvironment}-cgr2/WaitPipeline'
  dependsOn: [factory]
  properties: {
    activities: [
      {
        name: 'WaitActivity'
        type: 'Wait'
        typeProperties: {
          waitTimeInSeconds: 10
        }
      }
    ]
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'keyvault-forgeneraluse'
  scope: resourceGroup('commonResources')
}

module m_SqlServer 'modules/sql-server-and-db.bicep' = {
  name: 'SqlServer'
  params: {
    sqlserverpassword: serverPassword //kv.getSecret('SqlPassword')
    env: deploymentEnvironment
    location: resourcelocation
    SQLServerName: 'sql-bicep-${deploymentEnvironment}-cgr2'
    pin_aadUsername: 'clintgrove@microsoft.com' //kv.getSecret('aadUsername')
    pin_TenantId: '16b3c013-d300-468d-ac64-7eda0820b6d3' //kv.getSecret('tenant-id-secret')
  }
}


module m_StorageAccounts 'modules/storageaccount.bicep' = {
  name: 'StorageAccounts'
  params: {
    staccountname: 'cga${deploymentEnvironment}${uniqueString(resourceGroup().id)}'
    location: resourcelocation
    //whichenvironment: deploymentEnvironment
  }
}


