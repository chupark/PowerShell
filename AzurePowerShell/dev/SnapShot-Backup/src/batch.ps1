Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup\src\library\tools.psm1 -Force
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup\src\library\snapshotlib.psm1 -Force
## ------------------------------------------- you should change here ↓↓↓↓↓↓↓↓↓
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\carrot\carrot_storage.json" | ConvertFrom-Json

$loadedCSV = Import-CSV -Path "D:\4. 한화_인핏프로젝트\06. 백업\carrot-snapshot-2019-10-21.csv"

$vms = Get-AzVM

[Array]$diskarr = @()
foreach ($loadcsv in $loadedCSV) {
    $diskarr += $vms | Where-Object {$_.Name -eq $loadcsv.VM}
}

[Array]$diskLists = @()
foreach ($disk in $diskarr) {
    $disk.ResourceGroupName
    $diskLists += makeSnapshot -inputDiskNames ($disk.StorageProfile.DataDisks[0].Name) -vm ($disk) -snapshotResourceGroupName $disk.ResourceGroupName
    $diskLists += makeSnapshot -inputDiskNames ($disk.StorageProfile.OsDisk.Name) -vm ($disk) -snapshotResourceGroupName $disk.ResourceGroupName
}

$snapshotTable = makeSnapShotTable -snapshotNames $diskLists

$sass = generateSAS -snapshotTable $snapshotTable -destinationBlobInfo $storageConfig

sendToBlob -snapshotTable $snapshotTable -destinationBlobInfo $storageConfig

$snapShotNames = makeSnapshot $diskNamesForSnapshot $selectedVM $snapshotResourceGroupName
$snapshotTable = makeSnapShotTable -snapshotNames $snapShotNames
sendToBlob -snapshotTable $snapshotTable -destinationBlobInfo $storageConfig
$storageContext = New-AzStorageContext -StorageAccountName $storageConfig.storageAccountName -StorageAccountKey $storageConfig.storageAccountKey

do {
    $processing = Get-AzStorageBlob -Context $storageContext -Container $storageConfig.storageContainerName | Get-AzStorageBlobCopyState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Start-Sleep -Seconds 1
    $pending = $processing | Where-Object {$_.Status -eq "pending"}
    Write-Host Remain jobs.... $pending.count -ForegroundColor Green
} while($true)