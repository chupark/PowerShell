Import-Module -Name "D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-GetList\src\library\tools.psm1"

$col = @("resourceGroup", "sourceVM", "diskName", "sourceDisk")
$table = MakeTable -TableName "snapShotDisk" -ColumnArray $col

$snapShots = Get-AzSnapshot
$filteredSnapshots = $snapShots | Where-Object {$_.Name -match "BackupSnapshot-"}

foreach ($filteredSnapshot in $filteredSnapshots) {
    $Matches = $null
    # source Disk
    $tmp = $filteredSnapshot.CreationData.SourceResourceId -match "Microsoft.Compute/disks/(?<sourceDisk>.+)"
    $srcDisk = $Matches.sourceDisk
    $Matches = $null
    $tmp2 = $srcDisk -match "(?<vmName>.+)-(OS|DATA1|DATA)$"
    $srcVM = $Matches.vmName
    

    $row = $table.NewRow()
    # resourceGroup Name
    $row.resourceGroup = $filteredSnapshot.ResourceGroupName
    # source Disk
    $row.sourceDisk = $srcDisk
    # disk Name
    $row.diskName = $filteredSnapshot.Name
    # source VM
    $row.sourceVM = $srcVM
    $table.Rows.Add($row)
}

$table |Export-Csv "snapshotBackup.csv" -NoTypeInformation

#$zxcv = "P-distagingdb-DATA1"
#$tmp2 = $zxcv -match "(?<vmName>.+)-(OS|DATA1)$"; $Matches