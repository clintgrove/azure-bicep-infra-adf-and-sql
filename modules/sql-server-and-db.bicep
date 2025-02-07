@description('Data Factory Name')
param SQLServerName string = 'sql-bicep-test-cgr1'//'adf-bicep1-${uniqueString(resourceGroup().id)}'
@description('Location of the data factory.')
param location string = resourceGroup().location
@description('sql server password secure')
@secure()
param sqlserverpassword string
param env string
param pin_aadUsername string
param pin_TenantId string

resource sqlserver_rc 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: SQLServerName
  location: location
  tags: {
    CreateBy: 'Clinto'
    Useage: 'tagVal'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: sqlserverpassword
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: pin_aadUsername
      principalType: 'User'
      tenantId: pin_TenantId
    }
    // federatedClientId: 'string'
    // keyId: 'string'
    // minimalTlsVersion: 'string'
    // primaryUserAssignedIdentityId: 'string'
    publicNetworkAccess: 'Enabled'
    // restrictOutboundNetworkAccess: 'string'
    // version: 'string'
  }
}


resource sqldb_rc 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'db-${env}-bccga-1'
  location: location
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  sku: {
    //capacity: 5
    //family: 'string'
    name: 'Basic'
    //size: 'string'
    tier: 'Basic'
  }
  parent: sqlserver_rc
  // identity: {
  //   type: 'SystemAssigned'
  // }
  properties: {
    autoPauseDelay: 5
    // catalogCollation: 'string'
    // collation: 'string'
    // createMode: 'string'
    // elasticPoolId: 'string'
    // federatedClientId: 'string'
    // highAvailabilityReplicaCount: int
    // isLedgerOn: bool
    // licenseType: 'string'
    // longTermRetentionBackupResourceId: 'string'
    // maintenanceConfigurationId: 'string'
    // maxSizeBytes: int
    // minCapacity: json('decimal-as-string')
    // preferredEnclaveType: 'string'
    // readScale: 'string'
    // recoverableDatabaseId: 'string'
    // recoveryServicesRecoveryPointId: 'string'
    // requestedBackupStorageRedundancy: 'string'
    // restorableDroppedDatabaseId: 'string'
    // restorePointInTime: 'string'
    // sampleName: 'string'
    // secondaryType: 'string'
    // sourceDatabaseDeletionDate: 'string'
    // sourceDatabaseId: 'string'
    // sourceResourceId: 'string'
    // zoneRedundant: bool
  }
}


output sqlsrv string  = sqlserver_rc.id
