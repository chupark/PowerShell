$configFilePath = "$env:HOMEDRIVE$env:HOMEPATH\"
$configFileName = "vm_lb_infos.csv"

$vmLBConfigs = Import-Csv -Path "$configFilePath$configFileName"

$nics = Get-AzNetworkInterface
$vms = Get-AzVM

$matchedVMs = ''
$matchedNICs = ''


foreach ($vmLbConfig in $vmLbConfigs) {
    # lb 찾기
    $loadBalancer = Get-AzLoadBalancer -Name $vmLbConfig.LB_Name -ResourceGroupName $vmLbConfig.LB_ResourceGroup
    $backendPoolInfo = Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $loadBalancer -Name $vmLbConfig.LB_PoolName
    # VM csv 파일의 VM_Name과 일치하는 VM 찾기
    $obj1 = $vms | Where-Object {$_.Name -eq $vmLbConfig.VM_Name}
    # $obj1 변수에서 첫 번째 nic의 id와 // 로드된 모든 nic의 id와 비교하여 일치하는 nic 찾기
    $matchedNIC = $nics | Where-Object {$_.Id -eq $obj1.NetworkProfile.NetworkInterfaces[0].Id}
    if($matchedNIC.IpConfigurations[0].LoadBalancerBackendAddressPools.count -eq 0){
        $matchedNIC.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPoolInfo
        #$matchedNIC.IpConfigurations[0].LoadBalancerBackendAddressPools = 
    } elseif($matchedNIC.IpConfigurations[0].LoadBalancerBackendAddressPools -ne 0) {
        $matchedNIC.IpConfigurations[0].LoadBalancerBackendAddressPools += $backendPoolInfo
    } else {
        
    }
    Set-AzNetworkInterface -NetworkInterface $matchedNIC
}