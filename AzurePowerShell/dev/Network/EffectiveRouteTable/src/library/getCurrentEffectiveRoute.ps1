param (
    $nicResourceGroupName,
    $nicName,
    $errLogFileName
)
try {
    $jsonConfig = Get-Content -Raw -Path "D:\PowerShell\config.json" | ConvertFrom-Json
    $user = $jsonConfig.servicePrincipal.user
    $pass = ConvertTo-SecureString -String $jsonConfig.servicePrincipal.pass -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $user, $pass
    $account = Login-AzAccount -ServicePrincipal -Credential $cred -Tenant $jsonConfig.accountBasic.tenant -Subscription $jsonConfig.accountBasic.subscription -SkipContextPopulation
    $routeTable = Get-AzEffectiveRouteTable -ResourceGroupName $nicResourceGroupName -NetworkInterfaceName $nicName -ErrorAction SilentlyContinue -ErrorVariable anyError
    $routeTable | Add-Member -MemberType NoteProperty -Name "nicName" -Value $nicName
    $routeTable
    if ($anyError) {
        $errMsg = (Get-Date).ToString() + "`n" + $anyError + "`n"
        $errMsg >> C:\Users\cwpark\$errLogFileName
    }
} catch {
    $_.Exception.Message >> C:\Users\cwpark\allError.log
}