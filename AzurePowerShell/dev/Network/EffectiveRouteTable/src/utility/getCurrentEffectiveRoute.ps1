param (
    $nicResourceGroupName,
    $nicName,
    $errLogFileName
)
Import-Module D:\PowerShell\PowerShell\AzurePowerShell\dev\Network\EffectiveRouteTable\src\utility\logger.psm1 -Force
try {
    # change config file path here------------↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    $jsonConfig = Get-Content -Raw -Path "D:\PowerShell\config.json" | ConvertFrom-Json
    $user = $jsonConfig.servicePrincipal.user
    $pass = ConvertTo-SecureString -String $jsonConfig.servicePrincipal.pass -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $user, $pass
    $account = Login-AzAccount -ServicePrincipal -Credential $cred -Tenant $jsonConfig.accountBasic.tenant -Subscription $jsonConfig.accountBasic.subscription -SkipContextPopulation
    $routeTable = Get-AzEffectiveRouteTable -ResourceGroupName $nicResourceGroupName -NetworkInterfaceName $nicName -ErrorAction SilentlyContinue -ErrorVariable anyError
    $routeTable | Add-Member -MemberType NoteProperty -Name "nicName" -Value $nicName
    $routeTable
    if ($anyError) {
        # error --> log.error
        makeLogFile -logType "log.error" -fileName "error.log" -logMsg $anyError
    }
} catch {
    makeLogFile -logType "log.runtime" -fileName "runtime_error.log" -logMsg $_.Exception.Message
}