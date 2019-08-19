Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\library\tools.psm1 -Force
$scriptPath = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\library\getCurrentEffectiveRoute.ps1"

$vms = Get-AzVM
$resourceTable = $null
$routeTable = $null
$today = (Get-Date -Format "yyyy-MM-dd")
$yesterDay = (Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-dd")
$csvFileName = $today + "_route.csv"
$yesterDayCsvFileName = $yesterDay + "_route.csv"
$errLogFileName = $today + "_error.log"


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

#$compareOut = $out
#$compareOut

$thisTime = Import-Csv $csvFileName

#$lastTime = Import-Csv $yesterDayCsvFileName