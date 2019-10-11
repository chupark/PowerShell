Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\tools.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\snapshotlib.psm1 -Force

$snapshotListsCSVs = Import-Csv -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\diskLists.csv"
$programEnv = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\env.json" -Force | ConvertFrom-Json
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\storageInfo.json" -Force | ConvertFrom-Json

$backupDiskLists = getBackupItems -storageConfig $storageConfig -programEnv $programEnv

$today=Get-Date -Format "yyyy-MM-dd--HH-mm"


### Test
##$zz = $aa -match  "(?<year>.+)-(?<month>.+)-(?<day>.+)--(?<hour>.+)-(?<minute>.+)"
##Get-Date -Year $Matches.year -Month $Matches.month -Day $Matches.day -Hour $Matches.hour -Minute $Matches.minute -Second 0