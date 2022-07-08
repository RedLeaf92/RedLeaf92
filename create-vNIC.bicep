// Following code creates a vNIC for assignment to a VM //

@minLength(1)
@maxLength(15)
@description('Provide the name of the VM that will use this vNIC. Use only lower case letters and numbers.')
param vmName string

@description('Enter location. If you leave this field blank, resource group location would be used.')
param location string = resourceGroup().location

resource windowsVMNic 'Microsoft.Network/networkInterfaces@2020-11-01' =  {
  name: '${vmName}-NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '/subscriptions/bf810be9-4319-4110-ac9f-4483aec1bf78/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/networkInterfaces/${vmName}-NIC/ipConfigurations/ipConfig'
          }
        }
      }
    ]
  }
  tags: {
    Owner: ownerTag
    Project: projectTag
    Environment: environmentTag
  }
}
