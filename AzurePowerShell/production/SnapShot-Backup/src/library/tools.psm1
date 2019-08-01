## https://stackoverflow.com/questions/31409009/how-to-have-a-powershell-function-return-a-table

Function MakeTable ($TableName, $ColumnArray) {
    $table = New-Object System.Data.DataTable("$TableName")
    foreach($Col in $ColumnArray)
    {
        $MCol = New-Object System.Data.DataColumn $Col;
        $table.Columns.Add($MCol)

      }
    return , $table
}

# by me cwpark!

function findVMNameWithNICName ([String]$nicName, $inputVMS) {
    foreach ($inputVm in $inputVMS) {
        foreach ($nic in $inputVm.NetworkProfile.NetworkInterfaces.Id) {
            $aa = $nic -match "/Microsoft.Network/networkInterfaces/(?<nicName>.+)"
            if ($Matches.nicName.ToString() -eq $nicName) {
                return $inputVm.Name
            }
        }
    }
}


function makeSnapshot() {
    param (
        $inputDiskNames,
        $vm,
        $resourceGroupName
    )
    $diskLists = @()

    foreach ($inputDiskName in $inputDiskNames) {
        $diskSnapShotName = "BackupSnapshot-" + $vm.Name + "-" + $inputDiskName + "-" + (Get-Date -Format "yyyy-MM-dd")
        $sourceDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroup -DiskName $inputDiskName
        $diskSnapshotConfig = New-AzSnapshotConfig -SourceUri $sourceDisk.Id -Location $sourceDataDisk.Location -CreateOption copy
        $diskSnapshot = New-AzSnapshot -SnapshotName $diskSnapShotName -Snapshot $diskSnapshotConfig -ResourceGroupName $resourceGroupName
        $diskLists += $diskSnapShotName
    }

    return $diskLists
}