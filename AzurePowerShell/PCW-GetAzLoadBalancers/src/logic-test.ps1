$location = (Get-Location).Path
Import-module -NAme "$location\model\model.psm1"

$col=@("a", "b", "c")
$table = MakeTable "test" $col
$row = $table.NewRow()

$lbList = Get-AzLoadBalancer
$vm=Get-AzVM

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
    if ($lb.FrontendIpConfigurations[0].PublicIpAddress -eq $null) {
        $lbKind = "private"
    } else {
        $lbKind = "public"
        $lbIPS = "public"
    }
    foreach ($lbRule in $lb.LoadBalancingRules) {
        $FrontIPId = ($lbRule.FrontendIPConfiguration.Id | Select-String  $lbList.FrontendIpConfigurations.Id).ToString()
        $ruletmp = $lbRule.FrontendIPConfiguration.Id -match "/frontendIPConfigurations/(?<lbFrontIP>.+)"
        
        $FrontIP = $Matches.lbFrontIP
        $ruleProtocol = $lbRule.Protocol
        $ruleFrontEndPort = $lbRule.FrontendPort
        $ruleBackEndPort = $lbRule.BackendPort
    }
}