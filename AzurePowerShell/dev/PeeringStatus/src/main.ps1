Import-Module -Name "D:\PowerShell\PowerShell\AzurePowerShell\dev\library\vnet.psm1" -Force

$vnetPeeringRemoveDuplicate = vnetPeeringRemoveDuplicate
$vnetPeeringAll = vnetPeeringAll
vnetFinalPeering -vnetPeeringRemoveDuplicate $vnetPeeringRemoveDuplicate -vnetPeeringAll $vnetPeeringAll | ft

# vnetFinalPeering -vnetPeeringRemoveDuplicate $vnetPeeringRemoveDuplicate -vnetPeeringAll $vnetPeeringAll | export-CSV -Path "<yout-Path>"