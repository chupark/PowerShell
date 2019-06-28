# Import Module
$location = (Get-Location).Path
Import-module -Name "$location\src\library\tools.psm1"

# Making Data Table
$col=@("num", "lbName", "lbKind", "frontEndIP", "backEndPoolName", "backEndPool", "probeRule", "ruleProto", "rulePort")
$table = MakeTable "test" $col

# Get Row Data
$lbList = Get-AzLoadBalancer
$frontIpIds = $lbList.FrontendIpConfigurations.Id
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

    # ip만 알려주고 빠짐
    foreach ($frontIpId in $frontIpIds) {
        if ($lb.FrontendIpConfigurations.Id -eq $frontIpId) {
            if ($lb.FrontendIpConfigurations.PrivateIpAddress -ne $null) {
                Write-Host $lb.FrontendIpConfigurations.PrivateIpAddress
            } elseif ($lb.FrontendIpConfigurations.PublicIpAddress -ne $null) {
                Write-Host $lb.FrontendIpConfigurations.PublicIpAddress
            }
        }
    }

    foreach ($lbFront in $lb.FrontendIpConfigurations) {
        foreach ($lbBalancingRuleId in $lbFront.LoadBalancingRules.Id) {
            if ($lb.LoadBalancingRules.Id -eq $lbBalancingRuleId) {
                Write-Host $lbRule.BackendAddressPool.Id
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

}

# $table | Export-Csv $exportFilePath -NoTypeInformation