Import-Module -Name "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\library\logger.psm1" -Force
<#
param(

)
#>

$csvFileTest = Import-Csv -Path $hashFileName
$thisTime = $csvFileTest.Path[$csvFileTest.Count - 1]
$beforeTime = $csvFileTest.Path[$csvFileTest.Count - 2]
$thisTimeCSV = Import-Csv $csvFileTest.Path[$csvFileTest.Count - 1]
$beforeTimeCSV = Import-Csv $csvFileTest.Path[$csvFileTest.Count - 2]

$diff = Compare-Object -ReferenceObject $thisTimeCSV -DifferenceObject $beforeTimeCSV

if ($diff) {
    makeLogFile -logType "customLog.differentLog" -fileName "this.log" -logMsg "helpme222" 
}