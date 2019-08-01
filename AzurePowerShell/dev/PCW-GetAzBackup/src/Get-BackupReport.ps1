Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$location = (Get-Location).Path
Import-module -Name "$location\src\library\tools.psm1"

$col=@("Num", "WorkLoadName", "ResourceGroup", "Operation", "Status", "StartTime", "EndTime", "runningTime", "Size", "Speed")
$table = MakeTable "backupReport" $col

$rsVault = Get-AzRecoveryServicesVault
$rsVaultId = $rsVault[0].ID
$vms=Get-AzVM



## 하루마다 리포트 생성
$date=Get-Date
#$today = (Get-Date -Year $date.Year -Month $date.Month -Date $date.Day).AddHours(9).ToUniversalTime()
$today = (Get-Date -Year $date.Year -Month $date.Month -Date $date.Day).AddHours(9).AddDays(-6).ToUniversalTime()
$tomorrow = (Get-Date -Year $date.Year -Month $date.Month -Date $date.Day).addDays(2).AddHours(9).AddSeconds(-1).ToUniversalTime()
$jobs = Get-AzRecoveryServicesBackupJob -VaultId $rsVaultId -From $today -To $tomorrow -Operation Backup
$num = 1
foreach ($job in $jobs) {
    $size = ""
    $row=$table.NewRow()
    $zz = Get-AzRecoveryServicesBackupJobDetail -VaultId $rsVaultId -JobId $job.JobId
    $matchedItem = $vms | Where-Object {$_.Name -eq $zz.WorkloadName}
    if($zz.Status -match "Completed") {
        $tmpSize = ($zz.Properties.'Backup Size')
        $size = [int]$tmpSize.Substring(0, $tmpSize.LastIndexOf(" "))
    }
    $row.num = $num
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

    $num++
}

$table | Export-Csv haha.csv -NoTypeInformation 

$table | Select $col | Export-Excel "test.xlsx" -AutoSize -Append -WorksheetName "backupReport"