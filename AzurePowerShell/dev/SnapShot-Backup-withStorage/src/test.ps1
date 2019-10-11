Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\tools.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\snapshotlib.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\storagequery.psm1 -Force

# <!-- Load All Configs
$programEnv = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\env.json" -Force | ConvertFrom-Json
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\storageInfo.json" -Force | ConvertFrom-Json
$today=Get-Date -Format "yyyy-MM-dd--HH-mm"
$vms = Get-AzVM
# -->

$backupDiskLists = getBackupItems -storageConfig $storageConfig -programEnv $programEnv

# <!-- create DiskSnapShot & load lists
foreach ($backupDiskList in $backupDiskLists) {
    Start-Job -FilePath D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\launch\createDiskSnapshot.ps1 `
              -ArgumentList $backupDiskList, $today, $storageConfig, $programEnv
}
$backedupDiskLists = selectByPartitionKey -storageConfig $storageConfig -table "disktmp" -partitionKey "diskName"
$madenSnapshotList = getMadenSnapshot -backedupDiskLists $backedupDiskLists
# -->


# <!-- generate Snapshot SAS uri & load lists
foreach ($madenSnapshot in $madenSnapshotList) {
    Start-Job -FilePath D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\launch\generateSnapshotSAS.ps1 `
              -ArgumentList $madenSnapshot, $storageConfig, $programEnv
}
$encryptedSASs = selectByPartitionKey -storageConfig $storageConfig -table "sas" -partitionKey "encryptedSAS"
# -->

# <!-- Send To Blob
snapshotSendToBlob -encryptedSASs $encryptedSASs -storageConfig $storageConfig
# -->
$savedLists = selectByPartitionKey -storageConfig $storageConfig -table "savedLists"

$pending = checkTransationStatus -storageConfig $storageConfig

# <!-- Revoke SAS url
if(!$pending) {
    foreach ($encryptedSAS in $encryptedSASs) {
        Start-Job -FilePath D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\launch\revokeSnapshotSAS.ps1 -ArgumentList $encryptedSAS
    }
}
# ->


### Secure String Test ##########################################################################################################
# $aa = ConvertTo-SecureString $storageConfig.auth.key1 -AsPlainText -Force | ConvertFrom-SecureString -key (1..32)
# $bb = ConvertTo-SecureString $aa -Key (1..32)
# $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($bb)
# $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
#################################################################################################################################

## 
### Test
##$zz = $aa -match  "(?<year>.+)-(?<month>.+)-(?<day>.+)--(?<hour>.+)-(?<minute>.+)"
##Get-Date -Year $Matches.year -Month $Matches.month -Day $Matches.day -Hour $Matches.hour -Minute $Matches.minute -Second 0

#################################################################################################################################
<#
deleteByPartitionKey -storageConfig $storageConfig -table "disktmp" -partitionKey "diskName"
deleteByPartitionKey -storageConfig $storageConfig -table "sas" -partitionKey "encryptedSAS"
deleteByPartitionKey -storageConfig $storageConfig -table "savedLists"
#>

<#
$savedLists
$vmNameMatchedWithDisk = vmNameMatchedWithDisk -vms $vms
$tmpMatching = ($encryptedSAS.RowKey -match "BS-(?<diskName>.+)-D-[0-9`-]{0,50}").vmName
$Matches.diskName

$vmNameMatchedWithDisk | Where-Object {$_.Disk -eq $Matches.diskName}

$vms = Get-AzVM
$madenSnapshotList

Get-AzSnapshot | Remove-AzSnapshot
#>