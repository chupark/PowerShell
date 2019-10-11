Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\library\tools.psm1 -Force

$vms = Get-AzVM
$nics = Get-AzNetworkInterface

$date = Get-Date
[String]$convtDate = [String]$date.Year + "-" + [String]$date.Month + "-" + [String]$date.Day + " " + $date.Hour + ":" + $date.Minute + ":" + $date.Second
$col = @("vmResourceGroup", "vmName", "primary_NIC_privateIP")
$vmIPTable = MakeTable -TableName "vmIP" -ColumnArray $col
foreach ($vm in $vms) {
    $nicIDs = $vm.NetworkProfile.NetworkInterfaces.Id
    foreach ($nicID in $nicIDs) {
        $tmpNic = $nics | Where-Object {$_.Id -eq $nicID}
        if ($tmpNic.Primary) {
            $row = $vmIPTable.NewRow()
            $vmPrimaryIP = $tmpNic.IpConfigurations | Where-Object {$_.Primary -eq $true}
            $row.vmResourceGroup = $vm.ResourceGroupName
            $row.vmName = $vm.Name
            $row.primary_NIC_privateIP = $vmPrimaryIP.PrivateIpAddress
            $vmIPTable.Rows.Add($row)
        }
    }
}
$vmIPTable | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors | ConvertTo-Json > vmList.json

$vmIPTable | Export-Csv -NoTypeInformation -Path "ccccc.csv"

$incnt = 0
foreach ($tbl in $vmIPTable) {
    if ($tbl.vmName.StartsWith("P-")) {
        $incnt ++
    }
}

$sortedVMTable = $vmIPTable | sort -Property vmName





$nicID = $vms[52].NetworkProfile.NetworkInterfaces
$vmNic =  $nics | Where-Object {$_.Id -eq $nicID -and $_.Primary -eq $true}
$vmPrimaryIP = $vmNic.IpConfigurations | Where-Object {$_.Primary -eq $true}
$vmPrimaryIP.PrivateIpAddress



$col2 = @("vmResourceGroup", "vmName", "osType", "Extension")
$vmExtensionTable = MakeTable -TableName "vmExtension" -ColumnArray $col2
$omsCnt = 0
$runningCNT = 0
[array]$vmobj = $null
foreach ($vm in $vms) {
    if ($vm.Name.ToLower().StartsWith("p-")) {
        foreach ($vmExtension in $vm.Extensions) {
            $vmext = $vmExtension.Id -match "/extensions/(?<extensionName>.+)"
            if ($Matches.extensionName -eq "MicrosoftMonitoringAgent" -or $Matches.extensionName -eq "OmsAgentForLinux") {
                $row = $vmExtensionTable.NewRow()
                $row.vmResourceGroup = $vm.ResourceGroupName
                $row.vmName = $vm.Name
                if ($vm.OSProfile.WindowsConfiguration) {
                    $row.osType = "Windows"
                } elseif ($vm.OSProfile.LinuxConfiguration) {
                    $row.osType = "Linux"
                }
                $row.Extension = $Matches.extensionName
                $vmExtensionTable.Rows.Add($row)
                $vmobj += $vm
                $omsCnt ++           
            }
        }
        $runningCNT ++
    }
}