$lbList = Get-AzLoadBalancer

# 로드밸런서
$lbList[10]

# 프로브
$lbList[10].Probes[0]
$lbList[10].Probes[0].Protocol
$lbList[10].Probes[0].Port
$lbList[10].Probes[0].IntervalInSeconds
$lbList[10].Probes[0].NumberOfProbes

# 백엔드 풀
$lbList[10].BackendAddressPools[0]
$lbList[10].BackendAddressPools[0].BackendIpConfigurations.id

# 로드밸런싱 룰
$lbList[10].LoadBalancingRules[0]
$lbList[10].LoadBalancingRules[0].BackendAddressPool.Id
$lbList[10].LoadBalancingRules[0].Probe.Id
$lbList[10].LoadBalancingRules[0].Protocol
$lbList[10].LoadBalancingRules[0].IdleTimeoutInMinutes
$lbList[10].LoadBalancingRules[0].LoadDistribution

asdf