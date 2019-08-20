## Import Library
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\library\tools.psm1 -Force

## Global Variables
$vms = Get-AzVM
$resourceTable = $null
$routeTable = $null
$dt = Get-Date
$hashFileDate = (Get-Date $dt -Format "yyyy-MM-dd HH:mm:ss")
$today = (Get-Date $dt -Format "yyyy-MM-dd")
$yesterDay = (Get-Date $dt.AddDays(-1) -Format "yyyy-MM-dd")

## File Names & Path
$scriptPath = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\library\getCurrentEffectiveRoute.ps1"
$csvFileName = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\routeTable\" + $today + "_route.csv"
$yesterDayCsvFileName = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\routeTable\" + $yesterDay + "_route.csv"
$hashFileName = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\hash\fileHash.csv"
$errLogFileName = $today + "_error.log"

## 
foreach ($vm in $vms) {
    foreach ($tmpNicId in $vm.NetworkProfile.NetworkInterfaces) {
        $resourceTable += resourceKind -resourceId $tmpNicId.Id
    }
}

foreach ($rsTable in $resourceTable) {
    Start-Job -FilePath $scriptPath -ArgumentList $rsTable.resourceGroup, $rsTable.resourceName, $errLogFileName
}

#$routeTable
Get-job | Wait-Job
$out = Get-Job | Receive-Job -Keep
$out | Select-Object * -ExcludeProperty RunspaceId, PSComputerName, PSShowComputerName |
       Sort-Object -Property nicName, Name, DisableBgpRoutePropagation, State, Source, AddressPrefix, NextHopType, NextHopIpAddress |
       Export-csv  $csvFileName -NoTypeInformation
Get-Job | Remove-Job

$hash = Get-FileHash $csvFileName
$hash | Add-Member -MemberType NoteProperty -Name "date" -Value $hashFileDate
$hash | Export-Csv $hashFileName -NoTypeInformation -Append -Encoding UTF8

## 다른점 찾는 부분
## 모듈 분리 필요
$csvFileTest = Import-Csv -Path $hashFileName
$thisTime = Import-Csv $csvFileTest.Path[$csvFileTest.Count - 1]
$lastTime = Import-Csv $csvFileTest.Path[$csvFileTest.Count - 2]

#$thisTime = Import-Csv $csvFileName
#$lastTime = Import-Csv $yesterDayCsvFileName

$diff = Compare-Object -ReferenceObject $thisTime -DifferenceObject $lastTime
$diff.InputObject | Export-Csv -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\diff\diff.csv" -Encoding UTF8 -Append -NoTypeInformation