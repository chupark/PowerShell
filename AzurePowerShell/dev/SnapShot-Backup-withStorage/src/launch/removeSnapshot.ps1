param (
    [PSCustomObject]$oldDatas,
    [PSCustomObject]$programEnv,
    [PSCustomObject]$secretKey
)
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup-withStorage\src\svc\env.psm1 -Force
$encryptionConfig = getEncryptionConfig
$encryptionConfig.setSecretKey($secretKey)

$clientId = $encryptionConfig.getDecryptedString($programEnv.loginCred.clientId.ToString())
$passwd = $encryptionConfig.getDecryptedString($programEnv.loginCred.password.ToString())
$securePasswd = ConvertTo-SecureString $passwd -AsPlainText -Force
$mycred =  New-Object System.Management.Automation.PSCredential ($clientId, `
                                                                 $securePasswd)

Connect-AzAccount -Credential $mycred `
                  -Tenant $encryptionConfig.getDecryptedString($programEnv.loginCred.tenant) `
                  -Subscription $encryptionConfig.getDecryptedString($programEnv.loginCred.subscription)`
                  -ServicePrincipal

foreach ($oldData in $oldDatas) {
    Remove-AzSnapshot -ResourceGroupName $oldData.resourceGroup -SnapshotName $oldData.RowKey -Force
}