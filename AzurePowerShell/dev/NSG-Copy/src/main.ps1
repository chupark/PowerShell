$resourceGroup = "NSG-CopyTest"
$originNSG = "Origin-NSG"
$copyNSG = "Copy-NSG"

# Get Original NSG Object
$originNsgObject = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $originNSG
$originNsgObject | Get-Member | Select-String SecurityRules

# Make New NSG
New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $copyNSG -Location $originNsgObject.Location
$copyNsgObject = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $copyNSG
$copyNsgObject.SecurityRules = $originNsgObject.SecurityRules
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $copyNsgObject

az account show