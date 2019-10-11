$jsonConfig = Get-Content -Raw -Path "D:\PowerShell\config.json" | ConvertFrom-Json
$user = $jsonConfig.servicePrincipal.user
$pass = ConvertTo-SecureString -String $jsonConfig.servicePrincipal.pass -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $user, $pass
$account = Login-AzAccount -ServicePrincipal -Credential $cred -Tenant $jsonConfig.accountBasic.tenant -Subscription $jsonConfig.accountBasic.subscription -WarningAction SilentlyContinue

$vms = Get-AzVM -Status
$vms[0].PowerState | Get-Member
$fLists = $vms[0] | Get-Member -MemberType Property

Write-Host =================================== -ForegroundColor Green
foreach ($flist in $fLists.Name) {
    Write-Host $flist -ForegroundColor Red
    Write-Host $vms[0].$flist -ForegroundColor Yellow
    Write-Host =================================== -ForegroundColor Green
}

Write-Host $fLists[3]
<#
ResourceGroupName
Name
Location
VmSize
OsType
NIC
Provisioning
Zone
PowerState
MaintenanceAllowed
#>
$vms2 = Get-AzVM
$vms2[0].PowerState
$vms2[0] | Get-Member