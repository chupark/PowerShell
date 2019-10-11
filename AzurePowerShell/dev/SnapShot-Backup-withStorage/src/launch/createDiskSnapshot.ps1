param (
    [PSCustomObject]$backupDiskLists,
    [String]$today,
    [PSCustomObject]$storageConfig,
    [PSCustomObject]$programEnv
)
$logincred = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\logincred.json" | ConvertFrom-Json
$securePasswd = ConvertTo-SecureString $logincred.password -AsPlainText -Force
$mycred =  New-Object System.Management.Automation.PSCredential ($logincred.clientId, $securePasswd)
Connect-AzAccount -Credential $mycred -Tenant $logincred.tenant -ServicePrincipal

$sa = Get-AzStorageAccount -ResourceGroupName $storageConfig.saResourceGroup -StorageAccountName $storageConfig.saName
New-AzStorageTable -Name "disktmp" -Context $sa.Context
$saContext = $sa.Context
$snapshotSAS = (Get-AzStorageTable -Name "disktmp" -Context $saContext).CloudTable

[Array]$backedupDiskLists = @()
Write-Host $backupDiskLists
foreach ($backupDiskList in $backupDiskLists) {
    $diskSnapShotName = "BS-" + $backupDiskList.RowKey + "-D-" + $today
    Write-Host $diskSnapShotName
    try {
        $sourceDisk = Get-AzDisk -ResourceGroupName $backupDiskList.PartitionKey -DiskName $backupDiskList.RowKey -ErrorAction SilentlyContinue
        if($sourceDisk) {
            $diskSnapshotConfig = New-AzSnapshotConfig -SourceUri $sourceDisk.Id -Location $sourceDisk.Location -CreateOption copy        
            $diskSnapshot = New-AzSnapshot -SnapshotName $diskSnapShotName -Snapshot $diskSnapshotConfig -ResourceGroupName $sourceDisk.ResourceGroupName
        } else {
            
        }
    } catch {
        Write-Output $_.Exception
    } finally {

    }
    $backedupDiskLists += $diskSnapShotName
}

foreach ($backedupDiskList in $backedupDiskLists) {
    Add-AzTableRow `
    -table $snapshotSAS `
    -partitionKey "diskName" `
    -rowKey ("$backedupDiskList") `
    -property @{"diskName"="$backedupDiskList";}
}    
return ,$backedupDiskLists