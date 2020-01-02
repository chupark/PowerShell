########################################################################################################################################
# 데이터 디스크 스왑 스크립트
########################################################################################################################################
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\ChangeDataDisk\src\lib\helper.psm1 -Force

Write-Host "Now Loading...." -ForegroundColor Blue
Write-Host "Load ResourceGroups" -ForegroundColor Blue
$resourceGroups = Get-AzResourceGroup
Write-Host "Load VMs" -ForegroundColor Blue
$vms = Get-AzVM
Write-Host "Done" -ForegroundColor Blue


$resourceGroup = resourceGroupValid
$resourceGroup | Format-Table
Write-Host "Write Source VM" -ForegroundColor Yellow
$srcVM = vmValid -resourceGroup $resourceGroup
$srcVM | Format-Table
$srcVM.StorageProfile.DataDisks | Sort-Object -Property Lun | Format-Table
[PSCustomObject]$srcDataDisks = New-Object -TypeName $srcVM.StorageProfile.DataDisks.GetType()


Write-Host "Enter the Disk LUNs. The separator character is ," -ForegroundColor Yellow
Write-Host "ex) 1,2,3 // 0, 1, 2" -ForegroundColor Yellow
$luns = Read-Host -Prompt "LUNs"
$diskObjects = selectDataDisks -luns $luns -srcDataDisks $srcVM.StorageProfile.DataDisks
$diskObjects | Sort-Object Lun | Format-Table


Write-Host "Write Destination VM" -ForegroundColor Yellow
$dstVM = vmValid -resourceGroup $resourceGroup
$dstVM | Format-Table
Clear-Host

Write-Host "Source VM" -ForegroundColor Green
Write-Host "===============================================================================================================" -ForegroundColor Green
$srcVM | Format-Table

Write-Host
Write-Host "Destination VM" -ForegroundColor Green
Write-Host "===============================================================================================================" -ForegroundColor Green
$dstVM | Format-Table

Write-Host
Write-Host "Data Disk Lists" -ForegroundColor Green
Write-Host "===============================================================================================================" -ForegroundColor Green
$diskObjects | Format-Table
Write-Host "===============================================================================================================" -ForegroundColor Green

Write-Host "Enter y to continue" -ForegroundColor Blue
$outflag = Read-Host -Prompt "Continue?.."
if($outflag.ToLower() -ne "y") {
    Write-Host "Job is cancled."
    Write-Host "Bye."
    return;
}

## Remove Datadisks from Src VM
foreach($diskObject in $diskObjects) {
    $null = $srcVM.StorageProfile.DataDisks.Remove($diskObject)
}
Write-Host "Remove Datadisks for" $srcVM.Name
Update-AzVM -ResourceGroupName $srcVM.ResourceGroupName -VM $srcVM


## Attach Datadisks to Dst VM
foreach($diskObject in $diskObjects) {
    $null = $dstVM.StorageProfile.DataDisks.Add($diskObject)
}
Write-Host "Attach the Datadisks to" $dstVM.Name
Update-AzVM -ResourceGroupName $dstVM.ResourceGroupName -VM $dstVM