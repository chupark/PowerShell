Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\production\AzureBackup\src\library\tools.psm1 -Force

$col = @(
    "vaultName",
    "vmResourceGroup",
    "vmName",
    "backupPolicy"
)

$backupListTable = MakeTable "backupList" $col

$vault.Name
$vaults = Get-AzRecoveryServicesVault
foreach ($vault in $vaults) {
    $containers=Get-AzRecoveryServicesBackupContainer -VaultId $vault.ID -ContainerType "AzureVM"    
    foreach ($container in $containers) {
        $row = $backupListTable.NewRow()
        $Matches = $null
        $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vault.ID
        $backupItem.VirtualMachineId -match "/Microsoft.Compute/virtualMachines/(?<vmName>.+)"
        $row.vaultName = $vault.Name
        $row.vmResourceGroup = $vault.ResourceGroupName
        $row.vmName = $Matches.vmName
        $row.backupPolicy = $backupItem.ProtectionPolicyName
        $backupListTable.Rows.Add($row)
    }
}

$backupListTable | Export-Csv "backupItems.csv" -NoTypeInformation