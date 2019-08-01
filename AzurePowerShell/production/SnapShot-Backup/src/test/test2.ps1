$RecoveryPlanContext = Get-Content -raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\PCW-NewLoadBalancers\src\json\recoveryplancontext.json" | ConvertFrom-Json
$vmInfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name
$vms = $RecoveryPlanContext.VmMap
$vmMap = $RecoveryPlanContext.VmMap


foreach ($vmId in $vmInfo) {
    $vm = $vmMap.$VMID
    $azureVM = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.RoleName

    $regex = $azureVM.Name -match "(?<vmRegex>.+)-"
    $lbName = $Matches.vmRegex + "-LB"
    $lb = Get-AzLoadBalancer -ResourceGroupName $azureVM.ResourceGroupName -Name $lbName
    
    $azureNIC = Get-AzNetworkInterface -ResourceId $azureVM.NetworkProfile.NetworkInterfaces[0].Id
    
    $azureNIC.IpConfigurations[0].LoadBalancerBackendAddressPools.add($lb.BackendAddressPools[0])
    Set-AzNetworkInterface -NetworkInterface $azureNIC
}

Write-output