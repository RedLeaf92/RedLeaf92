@minLength(1)
@maxLength(15)
@description('Provide a name for the virtual machine. Use only lower case letters and numbers.')
param vmName string

@description('Enter location. If you leave this field blank, resource group location would be used.')
param location string = resourceGroup().location

@description('Select the size of VM that you would like.')
@allowed([
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B8ms'
])
param vmSize string

@description('Provide an administrator username for this VM')
param adminUserName string

@description('Provide a password for the administrator account')
@secure()
param adminPassword string

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

@minValue(1)
@maxValue(1024)
@description('Provide size of data Disk (Volume E:) in GB. e.g 1TB would be 1024GB. NOTE: The disk size cannot exceed 1TB')
param diskSizeVolume int

@description('Please enter a volume label for this disk. Excluding C or D.')
param volumeLabel string

// End of Paramater Declaration //


// Disk Creation //

resource datadiskE 'Microsoft.Compute/disks@2022-03-02' = {
  name: '${vmName}-${volumeLabel}'
  location: location
    sku: {
        name: 'Standard_LRS'
    }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: diskSizeVolume
  }
  tags: {
    Owner: ownerTag
    Project: projectTag
    Environment: environmentTag
  }
}

// NIC Creation //

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
            id: '/subscriptions/bf810be9-4319-4110-ac9f-4483aec1bf78/resourceGroups/SABP-Office365/providers/Microsoft.Network/virtualNetworks/SABP-vNet/subnets/SABP-Azure-vNet'
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

// VM Creation //

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location //resource location will be the same as the resource group
  properties: {
    hardwareProfile: {
      vmSize: vmSize  //Defines VMSize using parameter value defined in vmSize
    }
    osProfile: {
      computerName: vmName  //Creates VM using paramter value defined in vmName
      adminUsername: adminUserName  //Sets username using parameter value defined in adminUserName
      adminPassword: adminPassword  //Sets password using parameter value defined in adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Attach'
          managedDisk: {
            id: '/subscriptions/bf810be9-4319-4110-ac9f-4483aec1bf78/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/disks/${vmName}-E' //Uses VM Resource Group name and name of VM
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '/subscriptions/bf810be9-4319-4110-ac9f-4483aec1bf78/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/networkInterfaces/${vmName}-NIC'       
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  tags: {
    Owner: ownerTag
    Project: projectTag
    Environment: environmentTag
  }
}
