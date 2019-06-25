$location = (Get-Location).Path
Import-module -Name "$location\model.psm1"

# making table
$col=@("balancer", "kind", "ip", "backendPool", "nic", "probe", "rule")
$table = MakeTable "balancer" $col

$lbList = Get-AzLoadBalancer

$row = $table.NewRow()