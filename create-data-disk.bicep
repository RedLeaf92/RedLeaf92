// Following code creates a Data Disk for assignment to a VM //

@minLength(1)
@maxLength(15)
@description('Provide the name of the VM that will use this data-disk. Use only lower case letters and numbers.')
param vmName string

@minValue(1)
@maxValue(1024)
@description('Provide size of data disk in GB. e.g 1TB would be 1024GB. NOTE: The disk size cannot exceed 1TB')
param diskSizeVolume int

@description('Enter location. If you leave this field blank, resource group location would be used.')
param location string = resourceGroup().location

@description('Please enter a volume label for this disk. Excluding C or D.')
param volumeLabel string

resource datadisk 'Microsoft.Compute/disks@2022-03-02' = {
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
}
