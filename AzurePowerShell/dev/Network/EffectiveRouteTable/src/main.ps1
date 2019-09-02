## Import Library
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\library\tools.psm1 -Force
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\utility\compareDiff.ps1 -Force
Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\utility\logger.psm1 -Force

try {
    ## Global Variables
    $vms = Get-AzVM
    $resourceTable = $null
    $dt = Get-Date
    $hashFileDate = (Get-Date $dt -Format "yyyy-MM-dd HH:mm:ss")
    $todayFile = (Get-Date $dt -Format "yyyy-MM-dd HH_mm")

    ## File Names & Path
    $scriptPath = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\utility\getCurrentEffectiveRoute.ps1"
    $csvFileName = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\routeTable\" + $todayFile + "_route.csv"
    $hashFileName = "D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\outputs\hash\fileHash.csv"

    <#
    # 
    #>
    foreach ($vm in $vms) {
        foreach ($tmpNicId in $vm.NetworkProfile.NetworkInterfaces) {
            $resourceTable += resourceKind -resourceId $tmpNicId.Id
        }
    }

    <#
    
    #>
    foreach ($rsTable in $resourceTable) {
        Start-Job -FilePath $scriptPath -ArgumentList $rsTable.resourceGroup, $rsTable.resourceName
    }

    <# 
    # 테이블 만들어서 csv로 정리
    # 파일 저장 시 Hash 값을 csv 파일에 같이 저장함, 이 때 항상 순서가 같아야 하므로 정렬이 필요함
    # @@
    # output : $out
    # Type : Object[]
    #>
    $out = Get-job | Wait-job
    $out | Select-Object * -ExcludeProperty RunspaceId, PSComputerName, PSShowComputerName |
        Sort-Object -Property nicName, Name, DisableBgpRoutePropagation, State, Source, AddressPrefix, NextHopType, NextHopIpAddress |
        Export-csv  $csvFileName -NoTypeInformation
    Get-Job | Remove-Job

    <#
    # 저장한 파일의 Hash값을 따로 보관함
    # 파일의 내용이 일치하면 같은 Hash값을 가짐
    # @@
    # input : $csvFileName (파일 경로)
    # output : $hash
    # Type : Object[]
    #>
    $hash = Get-FileHash $csvFileName
    $hash | Add-Member -MemberType NoteProperty -Name "date" -Value $hashFileDate
    $hash | Export-Csv $hashFileName -NoTypeInformation -Append -Encoding UTF8

    <#
    # 다른점 찾기
    # Hash 파일 기록 csv 파일에 2개 이상 데이터 row가 있을 경우 작동
    # 가장 최신의 Hash 값과 그 이전의 Hash값을 비교함, Hash값이 다를 경우 변동이 있다고 판단
    # logs\diff 에 기록을 남기며, diff에 csv 비교를 시작한 시간의 이름으로 결과 파일을 남김
    # @@
    # input : $thisTime, $lastTime
    # Type : String
    # output : none
    #>
    $csvFileTest = Import-Csv -Path $hashFileName
    if($csvFileTest.Path.Count -ge 2) {
        $thisTime = $csvFileTest.Path[$csvFileTest.Count - 1]
        $beforeTime = $csvFileTest.Path[$csvFileTest.Count - 2]
        compareDiff -thisTime $thisTime -lastTime $beforeTime   
    }
} catch {
    makeLogFile -logType "log.runtime" -fileName "runtime_error.log" -logMsg $_.Exception.Message
}