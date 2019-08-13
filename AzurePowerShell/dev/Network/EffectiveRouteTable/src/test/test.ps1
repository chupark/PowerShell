$Matches = $null
$vms = Get-AzVM
$vm = $vms | Where-Object {$_.Name -match "P-clustermgr1"}
$nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id
$nic = Get-AzNetworkInterface -ResourceId $nicId
$routeTable = Get-AzEffectiveRouteTable -ResourceGroupName $nic.ResourceGroupName -NetworkInterfaceName $nic.Name