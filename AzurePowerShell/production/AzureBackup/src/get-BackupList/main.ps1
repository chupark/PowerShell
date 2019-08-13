Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\production\AzureBackup\src\library\tools.psm1 -Force

$col = @(
    "vaultName",
    "redundancy",
    "vmResourceGroup",
    "vmName",
    "scheduleFrequency",
    "scheduleRunDays",
    "dataRetention"
    "backupPolicyName"
)

$vms=Get-AzVM
$backupListTable = MakeTable "backupList" $col
$vaults = Get-AzRecoveryServicesVault

foreach ($vault in $vaults) {
    $containers=Get-AzRecoveryServicesBackupContainer -VaultId $vault.ID -ContainerType "AzureVM"    
    foreach ($container in $containers) {
        $row = $backupListTable.NewRow()
        $Matches = $null
        $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vault.ID
        $redundancy = Get-AzRecoveryServicesBackupProperties -Vault $vault
        $regex = $backupItem.VirtualMachineId -match "/Microsoft.Compute/virtualMachines/(?<vmName>.+)"
        $vmResourceGroupName = ($vms | Where-Object {$_.Name -eq $Matches.vmName}).ResourceGroupName
        $schedule = Get-AzRecoveryServicesBackupProtectionPolicy -Name $backupItem.ProtectionPolicyName -VaultId $vault.ID
        $row.vaultName = $vault.Name
        $row.redundancy = $redundancy.BackupStorageRedundancy
        $row.vmResourceGroup = $vmResourceGroupName
        $row.vmName = $Matches.vmName
        $row.scheduleFrequency = $schedule.SchedulePolicy.ScheduleRunFrequency
        if($schedule.RetentionPolicy.WeeklySchedule) {
            $row.scheduleRunDays = $schedule.RetentionPolicy.WeeklySchedule.DaysOfTheWeek -join "_"
            $row.dataRetention = [String]$schedule.RetentionPolicy.WeeklySchedule.DurationCountInWeeks + " W"
        } elseif ($schedule.RetentionPolicy.DailySchedule) {
            $row.scheduleRunDays = "everyDay"
            $row.dataRetention = [String]$schedule.RetentionPolicy.DailySchedule.DurationCountInDays + " D"
        }
        $row.backupPolicyName = $backupItem.ProtectionPolicyName
        $backupListTable.Rows.Add($row)
    }
}

$redundancy = Get-AzRecoveryServicesBackupProperties -Vault $vault
$backupListTable | Export-Csv "backupVMs.csv" -NoTypeInformation