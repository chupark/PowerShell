Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\SnapShot-Backup\src\library\tools.psm1 -Force
## Variables
[String]$inputResourceGroup = $null
[Array]$loadedVMs = $null
[String]$inputVM = $null
[Array]$vmList = $null
[Object]$selectedVM = $null
[String]$isOsDiskSnapshot = $null
[boolean]$isOsDiskWillTakeShapshot = $false
[Array]$diskNamesForSnapshot = @()
[int]$dataDiskCnt = 0
[Array]$inputSelectDataDisk = $null
[Array]$diskLUNs = $null
[String]$snapshotResourceGroupName = $null
[String]$snapShotNames = $null

## Input VM Resource Group
Write-Host 'Please enter the ResourceGroup Name' -ForegroundColor "Green" -NoNewline
$inputResourceGroup = Read-Host " "

$loadedVMs = Get-AzVM -ResourceGroupName $inputResourceGroup
Write-Host $loadedVMs.Name

## Input VM Name
Write-Host 'Please enter the VM Name' -ForegroundColor "Green" -NoNewline
$inputVM = Read-Host " "
$vmList = $inputVM.Replace(" ", "").Split(',')

$selectedVM = $loadedVMs | Where-Object {$_.Name -eq $vmList}
Write-Host $selectedVM.name

## Disk List of VM
Write-Host OS Disk : $selectedVM.StorageProfile.OsDisk.Name

## Select Os Disk Snapshot
Write-Host 'Do you want to make OS Disk Snapshot?  [ Yes y / No else]' -ForegroundColor "Green" -NoNewline
$isOsDiskSnapshot = Read-Host " "
if($isOsDiskSnapshot -eq "y") {
    $isOsDiskWillTakeShapshot = $true
    Write-Host A snapshot of the OS disk will be taken. -ForegroundColor Yellow
    $diskNamesForSnapshot += $selectedVM.StorageProfile.OsDisk.Name
} else {
    $isOsDiskWillTakeShapshot = $false
    Write-Host A snapshot of the OS disk will -NoNewline -ForegroundColor Yellow
    Write-Host "not" -NoNewline -ForegroundColor Red
    Write-Host be taken. -ForegroundColor Yellow
}

## Select Data Disks for Snapshot
Write-Host 'Select the Data disks' -ForegroundColor "Green"
foreach($dataDisks in $selectedVM.StorageProfile.DataDisks) {
    Write-Host [$dataDiskCnt] -NoNewline -ForegroundColor "Green"
    Write-Host DataDisk$dataDiskCnt  : $dataDisks.Name
    $dataDiskCnt ++
}
$inputSelectDataDisk = Read-Host "Select "

$diskLUNs = $inputSelectDataDisk.Replace(" ", "").Split(',')
foreach($diskLUN in $diskLUNs) {
    Write-Host A snapshot of the $selectedVM.StorageProfile.DataDisks[$diskLUN].Name will be taken. -ForegroundColor Yellow
    $diskNamesForSnapshot += $selectedVM.StorageProfile.DataDisks[$diskLUN].Name
}


## Ask Continue
Write-Host 'These disks will take snapshots.'
if($isOsDiskWillTakeShapshot) {
    Write-Host $diskNamesForSnapshot
} else {

}

Write-Host

Write-Host 'Select the ResourceGroup for snapshots' -ForegroundColor "Green" -NoNewline
$snapshotResourceGroupName = Read-Host " "


## $selectedVM.StorageProfile.OsDisk
## $selectedVM.StorageProfile.DataDisks[$diskLUN] $diskLUNs
Write-Host "[Disks] :" $diskNamesForSnapshot -ForegroundColor "yellow"
Write-Host "[Resource Group for Save] : " $snapshotResourceGroupName -ForegroundColor "yellow"
Write-Host 'Continue??  [ Yes y / No else ]' -ForegroundColor "Green" -NoNewline
$takeSnapShot = Read-Host " "

if ($takeSnapShot -eq "y") {
    # $snapShotNames = makeSnapshot $diskNamesForSnapshot $selectedVM $snapshotResourceGroupName
} else {
    return
}

foreach ($snapshotName in $snapshotNames.split(" ")) {
    Get-AzSnapshot -ResourceGroupName $snapshotResourceGroupName -SnapshotName  $snapshotName
    $row = $table.NewRow()
}

foreach ($osSnapShot in $osSnapShot) {
    $row = $table.NewRow()
    $aa = $snapshot.CreationData.SourceResourceId -match "/Microsoft.Compute/disks/(?<diskName>.+)"
    $disk = $Matches.diskName
    if($snapshot.Name -match "BackupSnapshot-") {
        
        $row.ResourceGroupName = $snapshot.ResourceGroupName
        $row.SnapShotName = $snapshot.Name
        $row.FromDisk = $disk
        $table.rows.add($row)
    }
}

foreach ($sourceBlob in $table) {
    $snapshotResourceGroupName = $sourceBlob.ResourceGroupName
    $snapShotName = $sourceBlob.SnapShotName
    $sasExpiryDuration = "86400"
    $storageAccountName = "cgibackupsnapshot"
    $storageContainerName = "backup-snapshots"
    $storageAccountKey = ""
    $destinationVHDFileName = $sourceBlob.FromDisk + ".vhd"
    $sas = Grant-AzSnapshotAccess -ResourceGroupName $snapshotResourceGroupName `
                                  -SnapshotName $snapShotName `
                                  -DurationInSecond $sasExpiryDuration `
                                  -Access Read
    
    $destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName `
                                               -StorageAccountKey $storageAccountKey
    
    Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS `
                            -DestContainer $storageContainerName `
                            -DestContext $destinationContext `
                            -DestBlob $destinationVHDFileName    
}