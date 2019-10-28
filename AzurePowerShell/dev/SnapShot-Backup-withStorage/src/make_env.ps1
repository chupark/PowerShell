# meta
# backupLists
# savedLists
# sas
# disktmp

Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\tools.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\snapshotlib.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\storagequery.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\svc\env.psm1 -Force


$snapshotListsCSVs = Import-Csv -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\diskLists.csv"
$programEnv = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\env.json" -Force | ConvertFrom-Json
$keyVaultConfig = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\keyvaultinfo.json" -Force | ConvertFrom-Json
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\storageInfo.json" -Force | ConvertFrom-Json



$envConfig = getEnvConfig
$envConfig.generateEncKey()
$envConfig.setkeyVaultConfig($keyVaultConfig)
$envConfig.sendKeyToVault($envConfig.genereatedKey)
$storedKey = $envConfig.getStoredKey()


$tableStorageConfig = getTableStorageConfig
$tableStorageConfig.setStorageConfig($storageConfig)


$encryptionConfig = getEncryptionConfig
$encryptionConfig.setSecretKey($storedKey.SecretValueText.Split(","))
$tmpcred = Get-Content -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\logincred.json" | ConvertFrom-Json
$programEnv.loginCred.clientId = $encryptionConfig.getEncryptedKeyString($tmpcred.clientId)
$programEnv.loginCred.password = $encryptionConfig.getEncryptedKeyString($tmpcred.password)
$programEnv.loginCred.tenant = $encryptionConfig.getEncryptedKeyString($tmpcred.tenant)
$programEnv.loginCred.subscription = $encryptionConfig.getEncryptedKeyString($tmpcred.subscription)


New-AzStorageTable -Context $tableStorageConfig.storageInfo.Context -Name "meta"
New-AzStorageTable -Context $tableStorageConfig.storageInfo.Context -Name "backupLists"
New-AzStorageTable -Context $tableStorageConfig.storageInfo.Context -Name "savedLists"
New-AzStorageTable -Context $tableStorageConfig.storageInfo.Context -Name "sas"
New-AzStorageTable -Context $tableStorageConfig.storageInfo.Context -Name "disktmp"


$cloudTable = $tableStorageConfig.getCloudTable("meta")
Add-AzTableRow -Table $cloudTable `
               -RowKey "allConfig" `
               -PartitionKey "config" `
               -propertyName "config" `
               -jsonString ($programEnv | ConvertTo-Json)
$config = (Get-AzTableRow -Table $cloudTable).config | ConvertFrom-Json
## Remove-AzTableRow -Table $cloudTable -PartitionKey "config" -RowKey "allConfig"



$cloudTable = $tableStorageConfig.getCloudTable($config.vmListsForBackup)
Add-AzTableRow -Table $cloudTable `
               -RowKey "backupList" `
               -PartitionKey "backupList" `
               -propertyName "backupList" `
               -jsonString ($snapshotListsCSVs | ConvertTo-Json)
$backupLists = $null
$backupLists = [String](Get-AzTableRow -Table $cloudTable).backupList | ConvertFrom-Json
## Remove-AzTableRow -Table $cloudTable -RowKey "backupList" -PartitionKey "backupList"