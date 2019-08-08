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


function makeSnapShotTable() {
    $col = @("ResourceGroupName", "SnapShotName", "FromDisk")
    $snapshotTable = MakeTable "snapShots" $col
    $allSnapshots = Get-AzSnapshot -ResourceGroupName $snapshotResourceGroupName

    foreach($snapshotName in $snapshotNames.split(" ")) {
        $Matches = $null
        $row = $snapshotTable.NewRow()
        $tmp = $allSnapshots | Where-Object {$_.Name -eq $snapshotName}
        $row.ResourceGroupName = $tmp.ResourceGroupName
        $row.SnapShotName = $tmp.Name
        $tmp2 = $tmp.CreationData.SourceResourceId -match "providers/Microsoft.Compute/disks/(?<diskName>.+)"
        $row.FromDisk = $Matches.diskName
        $snapshotTable.Rows.Add($row)
    }

    return ,@($snapshotTable)
}


function sendToBlob() {
    param(
        [PSCustomObject]$snapshotTable,
        [Object]$destinationBlobInfo
    )
    foreach ($snapshotBlob in $snapshotTable) {
        Write-Host $snapshotBlob.FromDisk
        $snapshotResourceGroupName = $snapshotBlob.ResourceGroupName
        $snapShotName = $snapshotBlob.SnapShotName
        $sasExpiryDuration = "86400"
        $storageAccountName = $destinationBlobInfo.storageAccountName
        $storageAccountKey = $destinationBlobInfo.storageAccountKey
        $storageContainerName = "test"
        $destinationVHDFileName = $snapshotBlob.FromDisk + ".vhd"
        
        $sas = Grant-AzSnapshotAccess -ResourceGroupName $snapshotResourceGroupName `
                                      -SnapshotName $snapShotName `
                                      -DurationInSecond $sasExpiryDuration `
                                      -Access Read
        
        $destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName `
                                                   -StorageAccountKey $storageAccountKey
        
        Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS `
                                -DestContainer $storageContainerName `
                                -DestContext $destinationContext `
                                -DestBlob $destinationVHDFileName    
    }   
}