param (
    [PSCustomObject]$madenSnapshotList,
    [PSCustomObject]$disktmp,
    [PSCustomObject]$storageConfig,
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


$sa = Get-AzStorageAccount -ResourceGroupName $storageConfig.saResourceGroup -StorageAccountName $storageConfig.saName
$saContext = $sa.Context
$snapshotSAS = (Get-AzStorageTable -Name "sas" -Context $saContext).CloudTable
try{
    foreach($madenSnapshot in $madenSnapshotList) {
        $sass = Grant-AzSnapshotAccess -ResourceGroupName $madenSnapshot.ResourceGroupName `
                                       -SnapshotName $madenSnapshot.Name `
                                       -DurationInSecond 21600 `
                                       -Access Read
        $sourceVM = $disktmp | Where-Object {$_.RowKey -eq $madenSnapshot.Name}
        $vmName = $sourceVM.vmName
        $snapshotName = $madenSnapshot.Name
        $resourceGroup = $madenSnapshot.ResourceGroupName
        $aa = (ConvertTo-SecureString $sass.AccessSAS -AsPlainText -Force | ConvertFrom-SecureString -key $secretKey)
        $resourceType = $madenSnapshot.Type
        Add-AzTableRow `
        -table $snapshotSAS `
        -partitionKey "encryptedSAS" `
        -rowKey ("$snapshotName") `
        -property @{"encryptedSAS"="$aa"; "resourceGroup"="$resourceGroup"; "resourceType"="$resourceType"; "vmName"="$vmName";}
    }
} catch {
    Write-Output $_.Exception
    return 
} finally {
    
}
