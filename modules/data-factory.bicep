@description('Data Factory Name')
param dataFactoryName string = 'adf-bicep-test-cgr1'//'adf-bicep1-${uniqueString(resourceGroup().id)}'

@description('Location of the data factory.')
param location string = resourceGroup().location


resource dataFactory_rc 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: {
    CreatedBy: 'Clint'
    CreateDate: '2022-01-01'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    globalParameters: {}
    publicNetworkAccess: 'Enabled'
    // repoConfiguration: {
    //   accountName: 'string'
    //   collaborationBranch: 'string'
    //   lastCommitId: 'string'
    //   repositoryName: 'string'
    //   rootFolder: 'string'
    //   type: 'string'
    //   // For remaining properties, see FactoryRepoConfiguration objects
    // }
  }
}
