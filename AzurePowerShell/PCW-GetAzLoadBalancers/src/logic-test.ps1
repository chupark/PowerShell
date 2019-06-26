$location = (Get-Location).Path
Import-module -Name "$location\src\library\tools.psm1"

$col=@("lbName", "lbKind", "frontEndIP", "backEndPoolName", "backEndPool", "ruleProto", "rulePort")
$table = MakeTable "test" $col
$row = $table.NewRow()

$lbList = Get-AzLoadBalancer
$vms=Get-AzVM

$lists = ($vm.NetworkProfile.NetworkInterfaces.Id -match "/Microsoft.Network/networkInterfaces/(?<vmNIC>.+)")

$lists[0].LastIndexOf("/")
$lists[0].Length

# 로드밸런서
$lb = $lbList[10]

# 프로브
$probe = $lb.Probes
$lbList[10].Probes[0].Name
$lbList[10].Probes[0].Protocol
$lbList[10].Probes[0].Port

# 백엔드 풀
$bakend = $lb.BackendAddressPools
$lbList[10].BackendAddressPools[0].Name
$lbList[10].BackendAddressPools[0].BackendIpConfigurations.id

# 로드밸런싱 룰
$lbList[10].LoadBalancingRules[0]
$lbList[10].LoadBalancingRules[0].BackendAddressPool.Id
$lbList[10].LoadBalancingRules[0].Probe.Id
$lbList[10].LoadBalancingRules[0].Protocol
$lbList[10].LoadBalancingRules[0].IdleTimeoutInMinutes

foreach ($lbProbe in $lb.Probes) {
    $probeName = $lbProbe.Name
    $probeProto = $lbProbe.Protocol
    $probePort = $lbProbe.Port
}


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
                $probeRule = $ProbeId.Protocol + " " +$ProbeId.Port
            }
        }
        $probeProto
        $probePort
        $ruleProtocol = $lbRule.Protocol
        $rulePort = [String]$lbRule.FrontendPort + " => " + [String]$lbRule.BackendPort

        Write-Host $lbName $lbKind $frontEndIP $lbBackEndName $backendPool $probeRule $ruleProtocol $rulePort
    }
}