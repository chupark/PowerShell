Import-Module -Name D:\PowerShell\PowerShell\AzurePowerShell\production\AzureBackup\src\library\tools.psm1 -Force


$ipRanges = Get-Content -Raw D:\PowerShell\PowerShell\AzurePowerShell\production\AzureIPRanges\statics\ServiceTags_Public_20190617.json | ConvertFrom-Json

$col = @(
    "name",
    "id",
    "region",
    "platform",
    "systemService",
    "addressPrefix"
)
$table = MakeTable "azureServiceIPs" $col
foreach ($ipRange in $ipRanges.values) {
    foreach ($porperites in $ipRange.properties) {
        foreach ($addressPrefix in $porperites.addressPrefixes) {
            $row = $table.NewRow()
            $row.name = $ipRange.Name
            $row.id = $ipRange.id
            $row.region = $porperites.region
            $row.platform = $porperites.platform
            $row.systemService = $porperites.systemService
            $row.addressPrefix = $addressPrefix
            $table.Rows.Add($row)
        }
    }
}

$table | Export-Csv "azureIpRanges.csv" -NoTypeInformation

Import-Module -Name D:\PowerShell\study\cidr\cidr.psm1 -Force
$cidr = getCidrCalculator
$azADs = $table | Where-Object {$_.name -eq "AzureActiveDirectory"}

[Array]$cidrArr = $null
foreach ($azAD in $azADs.addressPrefix) {
    $cidr.setCidr($azAD)
    $cidr.calculationCidr()
    $cidrArr += $cidr.cidrRange
}


$col = @("ip")
$table2 = makeTable -TableName "azureAD" -ColumnArray $col
foreach ($a in $cidrArr) {
    $row = $table2.NewRow()
    $row.ip = $a
    $table2.Rows.Add($row)
}
$table2 | Export-CSV "azureAD2.csv"