$resourceGroupName = "RG-PsLB"
## Making Virtual Network
<#
New-AzResourceGroup -ResourceGroupName "RG-PsLB" -Location "koreacentral"
New-AzVirtualNetwork -Name "RG-PsLB-Vnet" -Location "KoreaCentral" -ResourceGroupName "RG-PsLB" `
                     -AddressPrefix 20.0.0.0/16
$vnet = Get-AzVirtualNetwork -Name "RG-PsLB-Vnet" -ResourceGroupName "RG-PsLB"
Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Subnet01" -AddressPrefix 20.0.0.0/24
Set-AzVirtualNetwork -VirtualNetwork $vnet
#>

$lbSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name Subnet01

$lbFront = New-AzLoadBalancerFrontendIpConfig -Name "TestLB-FrontEnd" `
                                              -PrivateIpAddress "20.0.0.10"`
                                              -SubnetId $lbSubnet.Id

New-AzLoadBalancer -Name "TestLB" `
                   -ResourceGroupName $resourceGroupName `
                   -Sku Basic `
                   -FrontendIpConfiguration $lbFront `
                   -Location 'Korea Central'