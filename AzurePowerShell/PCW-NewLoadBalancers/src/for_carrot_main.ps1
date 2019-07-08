$location = (Get-Location).Path
$filePath = "C:\$env:HOMEPATH\lbrequest.xlsx"
Import-module -Name "$location\src\library\tools.psm1"
Import-module -Name "$location\src\library\compare-object-porperties.psm1"
$request = Import-Excel -Path $filePath -WorksheetName "request"
$col = @("Date", "request", "","BackendVMs", "Protocol", "Backend_Port", "Health_Proto", "Health_Port", "Session", "Session_Time", "updated")
$table = MakeTable "requestedLB" $col
$matchedItems = $request | Where-Object {$_.updated -eq "x"}


foreach ($matchedItem in $matchedItems) {
    $aa = $matchedItem.BackendVMs -match "(?<vmName>.+)\d"
    $matchedItem.LB_Name = $Matches.vmName
}


foreach ($cc in $matchedItems.LB_Name) {
    $cc = $matchedItem | Where-Object {$_.LB_Name -eq $matchedItem.LB_Name}
    $dd = $matchedItems | Where-Object {$_.LB_Name -eq $matchedItem.LB_Name}
    $vmName = ($dd.BackendVMs | select -Unique)
    foreach ($matchedItem in $matchedItems) {
        if ($matchedItem.LB_Name -eq $cc.LB_Name) {
            $matchedItem.BackendVMs = $vmName -join " "
        }
    }
}

$requestedLB = $matchedItems | select -Unique
$forCompare = Import-Excel -Path $filePath -WorksheetName "Sheet1"

## 반복문 돌면서 만들어진 matched item과 select-object 해서 P-dibs찾은거 비교해서 append 하던지 해야 함
Compare-ObjectProperties $requestedLB $forCompare
<#if(Compare-ObjectProperties $requestedLB $forCompare) {
    Write-Host "here"
} else {
    $requestedLB | Export-Excel -Path $filePath -Append -WorksheetName "Sheet1"
}
#>