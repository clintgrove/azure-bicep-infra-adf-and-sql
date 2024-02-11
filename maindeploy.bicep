//param uniqueSuffix string = substring(uniqueString(resourceGroup().id),0,6)

@description('ADX Database Name')
param resourcelocation string = resourceGroup().location

@description('password for server')
@secure()
param serverPassword string

@description('Which deployment environment DEV, TEST PROD etc')
param deploymentEnvironment string = 'dev'

//Deploy Factory
module factory 'br/public:avm/res/data-factory/factory:0.1.3' = {
  name: '${uniqueString(deployment().name, 'uksouth')}-adfdeploy-dffmin'
  params: {
    name: 'adf-bicep-${deploymentEnvironment}-cgr2'
    location: resourcelocation
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


