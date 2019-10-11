param (
    [PSCustomObject]$madenSnapshotList,
    [PSCustomObject]$storageConfig,
    [PSCustomObject]$programEnv
)
$logincred = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\logincred.json" | ConvertFrom-Json
$securePasswd = ConvertTo-SecureString $logincred.password -AsPlainText -Force
$mycred =  New-Object System.Management.Automation.PSCredential ($logincred.clientId, $securePasswd)
Connect-AzAccount -Credential $mycred -Tenant $logincred.tenant -ServicePrincipal

$sa = Get-AzStorageAccount -ResourceGroupName $storageConfig.saResourceGroup -StorageAccountName $storageConfig.saName
New-AzStorageTable -Name "sas" -Context $sa.Context
$saContext = $sa.Context
$snapshotSAS = (Get-AzStorageTable -Name "sas" -Context $saContext).CloudTable

foreach($madenShapshot in $madenSnapshotList) {
    $sass = Grant-AzSnapshotAccess -ResourceGroupName $madenShapshot.ResourceGroupName `
                                   -SnapshotName $madenShapshot.Name `
                                   -DurationInSecond 3600 `
                                   -Access Read

    $snapshotName = $madenShapshot.Name
    $resourceGroup = $madenShapshot.ResourceGroupName
    $aa = (ConvertTo-SecureString $sass.AccessSAS -AsPlainText -Force | ConvertFrom-SecureString -key (1..32))
    Add-AzTableRow `
    -table $snapshotSAS `
    -partitionKey "encryptedSAS" `
    -rowKey ("$snapshotName") `
    -property @{"encryptedSAS"="$aa"; "resourceGroup"="$resourceGroup"}
}