# Import Module
$location = (Get-Location).Path
Import-module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\PCW-GetAzLoadBalancers\src\library\tools.psm1

# Making Data Table
$col=@("num", "lbName", "lbKind", "frontEndIP", "backEndPoolName", "backEndPool", "probeRule", "backEndRuleProto", "LoadDistribution", "backEndRulePort")
$table = MakeTable "test" $col

# Get Row Data
$lbList = Get-AzLoadBalancer
$vms=Get-AzVM
$publicIPs = Get-AzPublicIpAddress

# Output Data
$exportFileName = "loadBalancer.csv"
$exportFilePath = "C:\Users\" + $env:USERNAME + "\" + $exportFileName

# Global Variable
$countnum = 1

foreach ($lb in $lbList) {
    $lbName = $lb.Name
    $lbKind = ""
    $lbIPs = ""
    $frontEndIP = ""
    $lbBackEndName = ""
    $probeRule = ""
    if ($lb.FrontendIpConfigurations[0].PublicIpAddress -eq $null) {
        $lbKind = "private"
    } else {
        $lbKind = "public"
        $lbIPS = "public"
    }
    
    if ($lbList.FrontendIpConfigurations.LoadBalancingRules.Length -eq 0) {

    }

    foreach ($lbRule in $lb.LoadBalancingRules) {
        $backendPool = ""
        $frontIP = $lbList.FrontendIpConfigurations | Where-Object {$_.Id -eq $lbRule.FrontendIPConfiguration.Id}
        if ($frontIP.PublicIpAddress) {
            $frontPIP = $publicIPs | Where-Object {$_.Id -eq $frontIP.PublicIpAddress.Id}
            $frontEndIP = $frontPIP.IpAddress
        } elseif ($frontIP.PrivateIpAddress) {
            $frontEndIP = $frontIP.PrivateIpAddress
        }

        foreach ($lbBackEndId in $lb.BackendAddressPools) {
            if ($lbrule.BackendAddressPool.ID -eq $lbBackEndId.Id) {
                $lbBackEndName = $lbBackEndId.Name
                foreach ($nic in $lbBackEndId.BackendIpConfigurations.Id) {
                    $tt = $nic -match "/networkInterfaces/(?<nicName>.+)/ipConfigurations/"
                    $backendPool += (findVMNameWithNICName $Matches.nicName $vms) + " "
                }
            }
        }

        foreach ($probeId in $lb.Probes) {
            if ($probeId.Id -eq $lbRule.Probe.Id) {
                $probeRule = $ProbeId.Protocol + " : " +$ProbeId.Port
            }
        }

        $ruleProtocol = $lbRule.Protocol
        $rulePort = [String]$lbRule.FrontendPort + " => " + [String]$lbRule.BackendPort
        $row = $table.NewRow()
        $row.num = $countnum
        $row.lbName = $lbName
        $row.lbKind = $lbKind
        $row.frontEndIP = $frontEndIP
        $row.backEndPoolName = $lbBackEndName
        $row.backEndPool = $backendPool
        $row.probeRule= $probeRule
        $row.backEndRuleProto = $ruleProtocol
        $row.LoadDistribution = $lbRule.LoadDistribution
        $row.backEndRulePort = $rulePort
        $table.Rows.Add($row)

        $countnum++
    }
}


$table | Export-Csv $exportFilePath -NoTypeInformation