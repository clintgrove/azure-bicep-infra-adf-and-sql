targetScope = 'subscription'

param environment string = 'dev'
param azlocation string = 'uksouth'
param nameofrg string = 'bicep-cga-${toLower(environment)}-uks-rg-01'

resource symbolicname 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: nameofrg
  location: azlocation
  tags: {
    Desc: 'for my cg real'
    Createdby: 'clint'
  }
}
