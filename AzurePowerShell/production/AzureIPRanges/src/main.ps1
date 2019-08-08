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