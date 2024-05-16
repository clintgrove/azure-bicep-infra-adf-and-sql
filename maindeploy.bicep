//param uniqueSuffix string = substring(uniqueString(resourceGroup().id),0,6)

@description('ADX Database Name')
param resourcelocation string = resourceGroup().location

@description('password for server')
@secure()
param serverPassword string

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

//Deploy Factory
module factory 'br/public:avm/res/data-factory/factory:0.1.3' = {
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
        value: 'dev'
      }
      infraGParam: {
        type: 'String'
        value: ''
      }
    }
  }
}
resource m_DataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'adf-bicep-${deploymentEnvironment}-cgr2/WaitPipeline'
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


module m_SqlServer 'modules/sql-server-and-db.bicep' = {
  name: 'SqlServer'
  params: {
    sqlserverpassword: serverPassword
    env: deploymentEnvironment
    location: resourcelocation
    SQLServerName: 'sql-bicep-${deploymentEnvironment}-cgr2'
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


