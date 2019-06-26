# Import Module
$location = (Get-Location).Path
Import-module -Name "$location\src\library\tools.psm1"

# Making Data Table
$col=@("num", "lbName", "lbKind", "frontEndIP", "backEndPoolName", "backEndPool", "probeRule", "ruleProto", "rulePort")
$table = MakeTable "test" $col

# Get Row Data
$lbList = Get-AzLoadBalancer
$vms=Get-AzVM

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
    foreach ($lbRule in $lb.LoadBalancingRules) {
        $backendPool = ""
        $FrontIPId = ($lbRule.FrontendIPConfiguration.Id | Select-String  $lbList.FrontendIpConfigurations.Id).ToString()
        ## Searching for FrontEndIP
        foreach ($fronttmp in $lb.FrontendIpConfigurations) {
            #$fronttmp
            if ($fronttmp.Id -eq $FrontIPId) {
                if ($fronttmp.PrivateIpAddress -ne $null) {
                    $frontEndIP = $fronttmp.PrivateIpAddress
                } elseif ($fronttmp.PublicIpAddress -ne $null) {
                    $frontEndIP = $fronttmp.PublicIpAddress
                } else {
                    $frontEndIP = $fronttmp.PrivateIpAddress + " : " + $fronttmp.PublicIpAddress
                }
            }
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
        $row.ruleProto = $ruleProtocol
        $row.rulePort = $rulePort
        $table.Rows.Add($row)

        $countnum++
    }
}

$table | Export-Csv $exportFilePath -NoTypeInformation