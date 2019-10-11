Start-Transcript -path "D:\logs\a.log" -Append -IncludeInvocationHeader 

## Import Custom Module
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\tools.psm1 -Force
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\library\snapshotlib.psm1 -Force

## Imporv backup vm list
$snapshotListsCSVs = Import-Csv -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\diskLists.csv"

## Import script config
$programEnv = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\env.json" -Force | ConvertFrom-Json
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\storageInfo.json" -Force | ConvertFrom-Json

New-AzStorageContainer -Name $programEnv.backupBlobName -Context $sa.Context -Permission Off

## Creating Azure Storage Table Services
Write-Output "Creating Table"
$sa = Get-AzStorageAccount -ResourceGroupName $storageConfig.saResourceGroup -StorageAccountName $storageConfig.saName
New-AzStorageTable -Name $programEnv.vmListsForBackup -Context $sa.Context
New-AzStorageTable -Name $programEnv.completedBackupList -Context $sa.Context

## Get Table Storage Information
Write-Output "Writing VM lists for making snapshots"
$a = $programEnv.vmListsForBackup
$saContext = $sa.Context
$backupLists = (Get-AzStorageTable -Name $a -Context $saContext).CloudTable

# $b = $programEnv.completedBackupList
# $cloudTable = (Get-AzStorageTable –Name $b –Context $saContext).CloudTable

## Writing Backup vm list to Table Services
Write-Output "Sends data to Azure Storage Table"
foreach ($snapshotListsCSV in $snapshotListsCSVs) {
    $vmName = $snapshotListsCSV.vmName 
    $rowKey = $snapshotListsCSV.Disk
    $resourceGroup = $snapshotListsCSV.resourceGroup
    Add-AzTableRow `
    -table $backupLists `
    -partitionKey $resourceGroup `
    -rowKey ("$rowKey") -property @{"vmName"="$vmName";}
}

## output 
$aaaa = Get-AzTableRow -Table $backupLists
Write-Output $aaaa

Stop-Transcript

<# Azure Table Storage 테스트
[string]$filter2 = [Microsoft.Azure.Cosmos.Table.TableQuery]::GenerateFilterCondition("PartitionKey", `
                        [Microsoft.Azure.Cosmos.Table.QueryComparisons]::Equal, "D-CH-RG")
$filterToDelete = Get-AzTableRow -Table $cloudTable -CustomFilter $filter2
$filterToDelete | Remove-AzTableRow -Table $backupLists                   

do {
    
} while ($true)
#>
$catalog=Get-AzReservationCatalog -Location koreacentral -ReservedResourceType VirtualMachines -SubscriptionId "814b80ef-928b-4f54-87c6-35df36270a65"
Select-AzSubscription -Subscription 814b80ef-928b-4f54-87c6-35df36270a65

Login-AzAccount

$catalogs = Get-AzReservationCatalog -Location koreacentral -ReservedResourceType VirtualMachines -SubscriptionId "85ae3d31-0850-429b-9c31-39573b109847"

$catalogs > haha.txt