param (
    [PSCustomObject]$encryptedSASs
)
$logincred = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\statics\storageConfig\logincred.json" | ConvertFrom-Json
$securePasswd = ConvertTo-SecureString $logincred.password -AsPlainText -Force
$mycred =  New-Object System.Management.Automation.PSCredential ($logincred.clientId, $securePasswd)
Connect-AzAccount -Credential $mycred -Tenant $logincred.tenant -ServicePrincipal

foreach ($encryptedSAS in $encryptedSASs) {
    Revoke-AzSnapshotAccess -ResourceGroupName $encryptedSAS.resourceGroup -SnapshotName $encryptedSAS.RowKey
}