
<#
.SYNOPSIS
리소스 그룹이 있는지 체크한다.

.DESCRIPTION
리소스 그룹을 입력받고 해당 리소스 그룹이 존재하는지 검증한다.

.EXAMPLE
An example

.NOTES
General notes
#>

function resourceGroupValid() {
    Write-Host "Write a Resource Group" -ForegroundColor Yellow
    do {
        $flag = $true
        $resourceGroupNamePrompt = Read-Host -Prompt "Resource Group"
        if($resourceGroupName = $resourceGroups | Where-Object {$_.ResourceGroupName.ToLower() -eq $resourceGroupNamePrompt.ToLower()}) {
            $flag = $false
        } else {
            Write-Host "Resource Group" $resourceGroupNamePrompt "is not exist. Please try again" -ForegroundColor Red
        }
    } while($flag)

    return $resourceGroupName;
}

<#
.SYNOPSIS
VM이 존재하는지 확인한다.

.DESCRIPTION
Long description

.PARAMETER resourceGroup
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function vmValid() {
    param(
        [PSCustomObject]$resourceGroup
    )
    do {
        $flag = $true
        $srcVmPrompt = Read-Host -Prompt "VM"
        if($srcVM = $vms | Where-Object {($_.Name.ToLower() -eq $srcVmPrompt.ToLower()) -and ($_.ResourceGroupName.ToLower() -eq $resourceGroup.ResourceGroupName.ToLower())}) {
            $flag = $false
        } else {
            Write-Host "VM" $srcVmPrompt "is not exist. Please try again" -ForegroundColor Red
        }
    } while($flag)
    
    return $srcVM
}


<#
.SYNOPSIS
교체할 디스크를 선택한다.

.DESCRIPTION
사용자는 원본 VM의 데이터 디스크를 LUN 번호를 입력하여 선택한다. 
함수는 선택한 DataDisk를 Microsoft.Azure.Management.Compute.Models.DataDisk데이터타입에 담아서 return 해 준다.
return된 데이터를 기반으로 원본 VM에서 DataDisk를 제거하고 목적지 VM에 DataDisk를 장착한다.
LUN번호는 원본과 같이 유지된다.

.PARAMETER luns
원본 데이터 디스크의 Lun 번호

.PARAMETER srcDataDisks
원본 VM의 데이터 디스크. $svcVM.storageProfile.Datadisks 를 사용한다.

.EXAMPLE
$luns = 0, 1, 2
$srcVM.StorageProfile.DataDisks
$diskObjects = selectDataDisks -luns $luns -srcDataDisks $srcVM.StorageProfile.DataDisks

.NOTES
Datadisk의 데이터 타입은 아래와 같다.
============================================================================================================
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     List`1                                   System.Object
============================================================================================================

기존 방법처럼 변수에 Where-Object를 사용하여 += 오퍼레이션으로 Add 하는 방식으로 값을 할당하면 Array 타입이 되므로 에러가 발생하게 된다.
따라서 Where-Object를 사용하여 찾은 Object를 임시 변수에 할당한 후 $srcVM.StorageProfile.DataDisks.Add($tmpVariable) 메서드를 사용해야 한다.

#>
function selectDataDisks() {
    param(
        [PSCustomObject]$luns,
        [PSCustomObject]$srcDataDisks
    )
    $srcDisk = New-Object -TypeName $srcDataDisks.GetType()
    foreach ($lun in $luns.Replace(" ", "").Split(",")) {
        $tmpadd = $srcVM.StorageProfile.DataDisks | Where-Object {$_.Lun -eq $lun}
        $srcDisk.Add($tmpadd)
    }
    return ,$srcDisk
}
