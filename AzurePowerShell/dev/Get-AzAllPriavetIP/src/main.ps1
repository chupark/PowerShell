Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\library\tools.psm1 -Force

$vnets = Get-AzVirtualNetwork
$nics = Get-AzNetworkInterface
$lbs = Get-AzLoadBalancer

$col = @("resource", "privateIP")
$tbl = MakeTable -TableName "ipTables" -ColumnArray $col

[Object]$resourceType = @("networkInterfaces", "loadBalancers")
foreach ($vnet in $vnets) {
    foreach ($subnet in $vnet.Subnets) {
        foreach ($subnetIP in $subnet.IpConfigurations) {
            $Matches = $null
            $null = $subnetIP.Id -match "providers/Microsoft.Network/(?<resourceKind>.[a-zA-Z]{0,40})"
            if ($Matches.resourceKind -in $resourceType) {
                # $aa = Get-NICIP -fullId $subnetIP.Id -resourceType $Matches.resourceKind -nics $nics -lbs $lbs 
                $row = $tbl.NewRow()
                $tbl.Rows.Add((Get-NICIP -fullId $subnetIP.Id -resourceType $Matches.resourceKind -nics $nics -lbs $lbs -table $row))
            }
        }
    }
}

function Get-NICIP() {
    param (
        [String]$fullId,
        [String]$resourceType,
        [PSCustomObject]$nics,
        [PSCustomObject]$lbs,
        [PSCustomObject]$tableRow
    )
    $Matches = $null
    $null = $subnetIP.Id -match "(?<resourceID>.+[a-zA-Z0-9]{0,300})/[a-zA-Z0-9]{0,100}/[a-zA-Z0-9]{0,100}"
    $resourceId = $Matches.resourceID
    if($resourceType-eq "networkInterfaces") {
        $nic = $nics | Where-Object {$_.Id -eq $resourceId}
        foreach ($nicip in $nic) {
            #Write-Host dtd $nicip.ResourceGroupName -- $nic.IpConfigurations.Name -- $nicIp.IpConfigurations.PrivateIpAddress
            $row.resource = $nic.IpConfigurations.Name
            $row.privateIP = $nicIp.IpConfigurations.PrivateIpAddress
        }
    } elseif ($resourceType -eq "loadBalancers") {
        $lb = $lbs | Where-Object {$_.Id -eq $resourceId}
        if($lb.FrontendIpConfigurations[0].PrivateIpAddress) {
            foreach ($lbFip in $lb.FrontendIpConfigurations) {
                #Write-Host dtd $lb.ResourceGroupName -- $lb.Name -- $lbFip.PrivateIpAddress
                $row.resource = $lb.Name
                $row.privateIP = $lbFip.PrivateIpAddress
            }
        }
    }
    return ,$row
}


##################### test
$lbs[0].Id
$tlb = $lbs | Where-Object {$_.Id -eq "/subscriptions/85ae3d31-0850-429b-9c31-39573b109847/resourceGroups/P-CH-RG/providers/Microsoft.Network/loadBalancers/P-apigw-LB"}
$tlb.FrontendIpConfigurations[0].PrivateIpAddress
$tnic = $nics | Where-Object {$_.Id -eq "/subscriptions/85ae3d31-0850-429b-9c31-39573b109847/resourceGroups/P-NW-RG/providers/Microsoft.Network/networkInterfaces/FW-A-ext"}
$tnic.IpConfigurations.PrivateIpAddress

$vmss = Get-AzVMss -ResourceGroupName D-CH-RG -VMScaleSetName vmssdis
$vmss_VMs = Get-AzVMss | Get-AzVmssVM