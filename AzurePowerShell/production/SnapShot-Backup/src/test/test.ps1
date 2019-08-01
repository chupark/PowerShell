# LB Resource Group
$resourceGroupName = "RG-PsLB"

# VM Resource Group
$vmResourceGroupName = "RG-PsLB"
$vmName = "VM-LBTest"

# lb Private Config
$lbVnetName = "RG-PsLB-Vnet"
$lbSubnetName = "Subnet01"
$lbName = "TestLB"
$lbLoaction = "Korea Central"

# lb FrontEnd Config
$lbFrontIPConfigName = "TestLB-FrontEnd"
$lbFrontIP_Private="20.0.0.10"

# lb Backend Name
$backEndPoolName = "BackendRule"

# lb Probe Config
$probeName = "probe_80"
$probePort = "80"

# configuring LB Rule
$lbRuleConfigName = "lbRule"
$lbProto = "TCP"
# distribution = [SourceIP | SourceIPProtocol | none]
$loadDistribution = "SourceIPProtocol"
$idleTimeoutMinute = 10
$frontPort = 80
$backendPort = 80

<#
## Making Virtual Network
New-AzResourceGroup -ResourceGroupName "RG-PsLB" -Location "koreacentral"
New-AzVirtualNetwork -Name "RG-PsLB-Vnet" -Location "KoreaCentral" -ResourceGroupName "RG-PsLB" `
                     -AddressPrefix 20.0.0.0/16
$vnet = Get-AzVirtualNetwork -Name "RG-PsLB-Vnet" -ResourceGroupName "RG-PsLB"
Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Subnet01" -AddressPrefix 20.0.0.0/24
Set-AzVirtualNetwork -VirtualNetwork $vnet

#>
$vnet = Get-AzVirtualNetwork -Name $lbVnetName -ResourceGroupName $resourceGroupName
$lbSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $lbSubnetName

$lbFront =  New-AzLoadBalancerFrontendIpConfig -Name $lbFrontIPConfigName `
                                               -PrivateIpAddress $lbFrontIP_Private `
                                               -SubnetId $lbSubnet.Id

New-AzLoadBalancer -Name $lbName `
                   -ResourceGroupName $resourceGroupName `
                   -Sku Basic `
                   -FrontendIpConfiguration $lbFront `
                   -Location $lbLoaction

$loadBalancer = Get-AzLoadBalancer -Name $lbName -ResourceGroupName $resourceGroupName
Add-AzLoadBalancerBackendAddressPoolConfig -Name $backEndPoolName -LoadBalancer $loadBalancer
$addedBackEndPool = Get-AzLoadBalancerBackendAddressPoolConfig -Name $backEndPoolName -LoadBalancer $loadBalancer
Set-AzLoadBalancer -LoadBalancer $loadBalancer
$lbFrontConfig = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $loadBalancer -Name $lbFrontIPConfigName
$backEndPool = Get-AzLoadBalancerBackendAddressPoolConfig -Name $backEndPoolName -LoadBalancer $loadBalancer

if ($loadBalancer.Probes.Name -match $probeName) {
    $probeInfo = Get-AzLoadBalancerProbeConfig -LoadBalancer $loadBalancer -Name $probeName   
} else {
    Add-AzLoadBalancerProbeConfig -LoadBalancer $loadBalancer -Name $probeName -Port $probePort -IntervalInSeconds 5 -ProbeCount 2
    Set-AzLoadBalancer -LoadBalancer $loadBalancer
}

if ($loadDistribution -match "none") {
    Add-AzLoadBalancerRuleConfig -LoadBalancer $loadBalancer -Name $lbRuleConfigName  `
                                 -Protocol $lbProto -ProbeId $probeInfo.Id `
                                 -FrontendPort $frontPort -BackendPort $backendPort `
                                 -BackendAddressPoolId $backEndPool.Id`
                                 -FrontendIpConfigurationId $lbFrontConfig.Id
} else {
    Add-AzLoadBalancerRuleConfig -LoadBalancer $loadBalancer -Name $lbRuleConfigName `
                                 -Protocol $lbProto -ProbeId $probeInfo.Id `
                                 -FrontendPort $frontPort -BackendPort $backendPort `
                                 -BackendAddressPoolId $backEndPool.Id`
                                 -LoadDistribution $loadDistribution -IdleTimeoutInMinutes $idleTimeoutMinute `
                                 -FrontendIpConfigurationId $lbFrontConfig.Id
}
Set-AzLoadBalancer -LoadBalancer $loadBalancer


## 백엔드 풀에 추가
$nics = Get-AzNetworkInterface -ResourceGroupName $vmResourceGroupName
foreach ($nic in $nics) {
    $aa = $nic.VirtualMachine.Id -match "/Microsoft.Compute/virtualMachines/(?<vmName>.+)"
    $bb = $Matches.vmName
    if($bb -match $vmName) {
        if($nic.IpConfigurations[0].LoadBalancerBackendAddressPools.count -eq 0) {
            $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $addedBackEndPool
        } elseif ($nic.IpConfigurations[0].LoadBalancerBackendAddressPools.Count -ne 0) {
            $nic.IpConfigurations[0].LoadBalancerBackendAddressPools += $addedBackEndPool
        } else {
            
        }
    }
    Set-AzNetworkInterface -NetworkInterface $nic
}