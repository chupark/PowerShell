$exportFileName="nsgRules.csv"
 
# <!-- Making Model
$tableName = "azureNsgRuleTables"
$table = New-Object System.Data.DataTable "$tableName"
$col0 = New-Object System.Data.DataColumn resourceGroupName,([string])
$col1 = New-Object System.Data.DataColumn nsgName,([string])
$col2 = New-Object System.Data.DataColumn ruleName,([string])
$col3 = New-Object System.Data.DataColumn priority,([string])
$col4 = New-Object System.Data.DataColumn access,([string])
$col5 = New-Object System.Data.DataColumn direction,([string])
$col6 = New-Object System.Data.DataColumn protocol,([string])
$col7 = New-Object System.Data.DataColumn sourceAddress,([string])
$col8 = New-Object System.Data.DataColumn sourcePort,([string])
$col9 = New-Object System.Data.DataColumn sourceASG,([string])
$col10 = New-Object System.Data.DataColumn destinationAddress,([string])
$col11 = New-Object System.Data.DataColumn destinationPort,([string])
$col12 = New-Object System.Data.DataColumn destinationASG,([string])
 
$table.Columns.add($col0)
$table.Columns.add($col1)
$table.Columns.add($col2)
$table.Columns.add($col3)
$table.Columns.add($col4)
$table.Columns.add($col5)
$table.Columns.add($col6)
$table.Columns.add($col7)
$table.Columns.add($col8)
$table.Columns.add($col9)
$table.Columns.add($col10)
$table.Columns.add($col11)
$table.Columns.add($col12)
# -->
 
 
$resourceGroups = Get-AzResourceGroup
foreach ($resourceGroupName in $resourceGroups) {
    $nsgList = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName.ResourceGroupName
    foreach ($nsg in $nsgList){
        $rules = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg
        # <!-- Making View
        foreach ($rule in $rules) {
            $srcIPs = $rule.SourceAddressPrefix
            $srcPorts = $rule.SourcePortRange
            $srcASGs = $rule.SourceApplicationSecurityGroups.Id
            $dstIPs = $rule.DestinationAddressPrefix
            $dstPorts = $rule.DestinationPortRange
            $dstASGs = $rule.SourceApplicationSecurityGroups.Id
            # <!-- For Empty Entity
            if($srcIPs.Count -eq 0) {
                $srcIPs = "-"
            }
            if($srcPorts.Count -eq 0) {
                $srcPorts = "-"
            }
            if($srcsrcASGsIPs.Count -eq 0) {
                $srcASGs = "-"
            }
            if($dstIPs.Count -eq 0) {
                $dstIPs = "-"
            }
            if($dstPorts.Count -eq 0) {
                $dstPorts = "-"
            }
            if($dstASGs.Count -eq 0) {
                $dstASGs = "-"
            }
            # -->
            foreach ($srcIP in $srcIPs) {
                foreach ($srcPort in $srcPorts) {
                    foreach ($srcASG in $srcASGs) {
                        foreach ($dstIP in $dstIPs) {
                            foreach ($dstPort in $dstPorts) {
                                foreach ($dstASG in $dstASGs) {
                                    $row = $table.NewRow()
                                    $row.resourceGroupName = $nsg.ResourceGroupName
                                    $row.nsgName = $nsg.Name
                                    $row.ruleName = $rule.Name
                                    $row.priority = $rule.Priority
                                    $row.access = $rule.Access
                                    $row.direction = $rule.Direction
                                    $row.protocol = $rule.Protocol
                                    $row.sourceAddress = $srcIP
                                    $row.sourcePort = $srcPort
                                    $row.sourceASG = $srcASG
                                    $row.destinationAddress = $dstIP
                                    $row.destinationPort = $dstPort
                                    $row.destinationASG = $dstASG
                                    $table.Rows.Add($row)
                                }
                            }
                        }
                    }
                }
            }
        }
        # -->
    }
}

$priority = $table.priority

