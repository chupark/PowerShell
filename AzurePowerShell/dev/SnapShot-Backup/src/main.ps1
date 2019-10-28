Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup\src\library\tools.psm1 -Force
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\SnapShot-Backup\src\library\snapshotlib.psm1 -Force
## ------------------------------------------- you should change here ↓↓↓↓↓↓↓↓↓
$storageConfig = Get-Content -Raw -Path "D:\PowerShell\carrot\carrot_storage.json" | ConvertFrom-Json
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

if($inputSelectDataDisk) {
$diskLUNs = $inputSelectDataDisk.Replace(" ", "").Split(',')
    foreach($diskLUN in $diskLUNs) {
        Write-Host A snapshot of the $selectedVM.StorageProfile.DataDisks[$diskLUN].Name will be taken. -ForegroundColor Yellow
        $diskNamesForSnapshot += $selectedVM.StorageProfile.DataDisks[$diskLUN].Name
    }
}


## Ask Continue
Write-Host 'These disks will take snapshots.'
if($isOsDiskWillTakeShapshot) {
    Write-Host $diskNamesForSnapshot
} else {

}

Write-Host

Write-Host 'Select the ResourceGroup for storing snapshots' -ForegroundColor "Green" -NoNewline
$snapshotResourceGroupName = Read-Host " "


## $selectedVM.StorageProfile.OsDisk
## $selectedVM.StorageProfile.DataDisks[$diskLUN] $diskLUNs
Write-Host "[Disks] :" $diskNamesForSnapshot -ForegroundColor "yellow"
Write-Host "[Resource Group for Save] : " $snapshotResourceGroupName -ForegroundColor "yellow"
Write-Host 'Continue??  [ Yes y / No else ]' -ForegroundColor "Green" -NoNewline
$takeSnapShot = Read-Host " "


if ($takeSnapShot -eq "y") {
    $snapShotNames = makeSnapshot $diskNamesForSnapshot $selectedVM $snapshotResourceGroupName
} else {
    return
}

$snapshotTable = makeSnapShotTable -snapshotNames $snapShotNames

## Send Snapshots To Blob
sendToBlob -snapshotTable $snapshotTable -destinationBlobInfo $storageConfig
$storageContext = New-AzStorageContext -StorageAccountName $storageConfig.storageAccountName -StorageAccountKey $storageConfig.storageAccountKey
$pending = Get-AzStorageBlob -Context $storageContext -Container $storageConfig.storageContainerName | Get-AzStorageBlobCopyState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

do {
    $pending = Get-AzStorageBlob -Context $storageContext -Container $storageConfig.storageContainerName | Get-AzStorageBlobCopyState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    $copyState = $pending.Status | Where-Object {$_ -eq "Pending"}
    Write-Host $copyState.Count
    Start-Sleep -Seconds 5
} while ($copyState)

<#
foreach ($blobCopyState in $blobCopyStates) {
    if ($blobCopyState.Status -eq "Success") {
        #$blobCopyState.Source
        
    } else {
        Write-Host Not-Completed
    }
}

$sss = Get-AzSnapshot -ResourceGroupName $snapshotTable[0].ResourceGroupName -SnapshotName $snapshotTable[0].SnapShotName
$blobCopyState.Source

Get-AzSnapshot | Revoke-AzSnapshotAccess
#>
