function makeSnapshot() {
    param (
        $inputDiskNames,
        $vm,
        $snapshotResourceGroupName
    )
    $diskLists = @()
    foreach ($inputDiskName in $inputDiskNames) {
        
        $diskSnapShotName = "BackupSnapshot-" + $vm.Name + "-" + $inputDiskName + "-" + (Get-Date -Format "yyyy-MM-dd")
        if($diskSnapShotName -match "P-cpbxmgr") {
            $aa = $zxcv -match "(?<prefix>.+)_[a-zA-Z0-9]{0,100}-(?<end>.+)"
            $diskSnapShotName = $Matches.prefix + "_" + $Matches.end
        }
        $sourceDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroup -DiskName $inputDiskName
        $diskSnapshotConfig = New-AzSnapshotConfig -SourceUri $sourceDisk.Id -Location $sourceDisk.Location -CreateOption copy
        $diskSnapshot = New-AzSnapshot -SnapshotName $diskSnapShotName -Snapshot $diskSnapshotConfig -ResourceGroupName $snapshotResourceGroupName
        $diskLists += $diskSnapShotName
    }

    return ,$diskLists
}


function makeSnapShotTable() {
    param (
        $snapshotNames
    )
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

function generateSAS() {
    param (
        [PSCustomObject]$snapshotTable,
        [Object]$destinationBlobInfo
    )
    [Array]$sas = @()
    foreach ($snapshotBlob in $snapshotTable) {
        $snapshotResourceGroupName = $snapshotBlob.ResourceGroupName
        $snapShotName = $snapshotBlob.SnapShotName
        $storageAccountName = $destinationBlobInfo.storageAccountName
        $storageAccountKey = $destinationBlobInfo.storageAccountKey
        $destinationVHDFileName = $snapshotBlob.SnapShotName + ".vhd"
                
        $sas += Grant-AzSnapshotAccess -ResourceGroupName $snapshotResourceGroupName `
                                      -SnapshotName $snapShotName `
                                      -DurationInSecond $destinationBlobInfo.sasExpiryDuration `
                                      -Access Read
    }
    return ,$sas
}

function sendToBlob() {
    param(
        [PSCustomObject]$snapshotTable,
        [Object]$destinationBlobInfo
    )
    foreach ($snapshotBlob in $snapshotTable) {
        $snapshotResourceGroupName = $snapshotBlob.ResourceGroupName
        $snapShotName = $snapshotBlob.SnapShotName
        $storageAccountName = $destinationBlobInfo.storageAccountName
        $storageAccountKey = $destinationBlobInfo.storageAccountKey
        $destinationVHDFileName = $snapshotBlob.SnapShotName + ".vhd"
                
        $sas = Grant-AzSnapshotAccess -ResourceGroupName $snapshotResourceGroupName `
                                      -SnapshotName $snapShotName `
                                      -DurationInSecond $destinationBlobInfo.sasExpiryDuration `
                                      -Access Read
        
        $destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName `
                                                   -StorageAccountKey $storageAccountKey
        
        Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS `
                                -DestContainer $destinationBlobInfo.storageContainerName `
                                -DestContext $destinationContext `
                                -DestBlob $destinationVHDFileName    
    }   
}


<#
$snapshotResourceGroupName = <스냅샷 리소스 그룹>
$snapShotName = <스냅샷 이름>
$sasExpiryDuration = <스냅샷 SAS URL 만료 시간 (초)>

$storageAccountName = <저장소 계정 이름>
$storageAccountKey = <저장소 계정 Key>
$destinationVHDFileName = <저장소 계정에 저장될 파일 이름> + ".vhd"
$storageContainerName = <저장소 계정 컨테이너 이름>
        
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

#>