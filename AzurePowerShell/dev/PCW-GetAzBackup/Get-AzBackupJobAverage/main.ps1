Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\production\AzureBackup\src\library\tools.psm1 -Force

$col=@("WorkLoadName", "ResourceGroup", "Operation", "Status", "StartTime", "EndTime", "runningTime", "Size", "Speed")
$table = MakeTable "backupReport" $col

$rsVault = Get-AzRecoveryServicesVault -ResourceGroupName P-IF-RG
#$rsVaultId = $rsVault[0].ID
$vms=Get-AzVM



## 하루마다 리포트 생성
$date=Get-Date -Year 2019 -Month 7 -Day 1
$adate=Get-Date -Year 2019 -Month 7 -Day 30
#$today = (Get-Date -Year $date.Year -Month $date.Month -Date $date.Day).AddHours(9).ToUniversalTime()
$today = (Get-Date -Year $date.Year -Month $date.Month -Date $date.Day).AddHours(9).ToUniversalTime()
$tomorrow = $today.AddMonths(1).AddDays(-1).ToUniversalTime()
$num = 1
foreach ($rsvaultID in $rsVault.id) {
    $jobs = Get-AzRecoveryServicesBackupJob -VaultId $rsVaultId -From $today -To $tomorrow -Operation Backup
    foreach ($job in $jobs) {
        $size = ""
        $row=$table.NewRow()
        $zz = Get-AzRecoveryServicesBackupJobDetail -VaultId $rsVaultId -JobId $job.JobId
        $matchedItem = $vms | Where-Object {$_.Name -eq $zz.WorkloadName}
        if($zz.Status -match "Completed") {
            $tmpSize = ($zz.Properties.'Backup Size')
            $size = [int]$tmpSize.Substring(0, $tmpSize.LastIndexOf(" "))
        }
        $row.WorkLoadName = $matchedItem.Name
        $row.ResourceGroup = $matchedItem.ResourceGroupName
        $row.Operation = $zz.Operation
        $row.Status = $zz.Status
        $row.StartTime = $zz.StartTime.AddHours(9).toString()

        $row.EndTime = $zz.EndTime.AddHours(9)
        $tt = ($zz.EndTime - $zz.StartTime)
        $row.runningTime = [String]$tt.Days + "d " + [String]$tt.Hours + ":" + [String]$tt.Minutes + ":" + [String]$tt.Seconds
        $row.Size = $size
        $row.Speed = [String]("{0:f2}" -f ([float]$size / [float]$tt.TotalSeconds)) + " mb/s"

        $table.rows.Add($row)
    }
}

$sortedVMs = $table.WorkLoadName | Sort-Object -Property ResourceGroup | select -Unique
$finalTable = MakeTable "finalReport" $col
foreach ($sortedVM in $sortedVMs) {
    $items = $table | Where-Object {$_.WorkLoadName -eq $sortedVM}
    $item = $items | Select-Object -Last 1 
    $row2 = $finalTable.NewRow()
    for ($i = 0; $i -lt $col.Count; $i++) {
        $row2[$i] = $item[$i]
    }
    $finalTable.Rows.Add($row2)
}
$finalTable | Sort-Object -Property ResourceGroup | Export-Csv -Encoding UTF8 -NoTypeInformation -Path "finalBackupReport.csv"

# $table | Export-Csv haha.csv -NoTypeInformation -Encoding UTF8

# $table | Select $col | Export-Excel "test.xlsx" -AutoSize -Append -WorksheetName "backupReport" -Encoding UTF8