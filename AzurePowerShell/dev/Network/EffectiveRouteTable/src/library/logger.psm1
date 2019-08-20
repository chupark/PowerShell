function makeLogFile() {
    param (
        [String]$logType,
        [String]$fileName,
        $logMsg,
        $timeZone
    )
    $config = Get-Content -Raw -Path "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\statics\logConfig.json" | ConvertFrom-Json
    $splited = $logType.Split(".")
    $i = 0
    for ($i = 0; $i -lt $splited.Count; $i++) {
        New-Variable -Name "log$i" -Value $splited[$i]
    }
    for ($i = 0; $i -lt $splited.Count; $i++) {
        $aa = (Get-Variable -Name "log$i").Value
        if ($i -eq 0) {
            $pathTest = $config.$aa
        } else {
            $pathTest = $pathTest.$aa
        }
    }  
    $fileFullPath = $pathTest + $fileName
    $fullMsg = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + "`n" + $logMsg + "`n"
    $fullMsg >> $fileFullPath
}

# makeLogFile -logType "customLog2.a.b.c" -fileName "this2.log" -logMsg "helpme2222222" 