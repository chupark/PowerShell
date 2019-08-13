Import-Module -Name "D:\PowerShell\PowerShell\AzurePowerShell\dev\library\tools.psm1" -Force

$nics = Get-AzNetworkInterface
$vms = Get-AzVM

function resourceKind() {
    param(
        [String]$resourceId
    )
    $Matches = $null
    $col = @("module", "resourceKind", "resourceGroup", "resourceName")
    $resourceTable = MakeTable -TableName "resourceTable" -ColumnArray $col
    $resourceRegex = $resourceId -match "/resourceGroups/(?<resourceGroup>.+)/providers/Microsoft.(?<module>.+)/(?<resourceKind>.+)/(?<resourceName>.+)"
    $row = $resourceTable.NewRow()
    $row.module = $Matches.module
    $row.resourceKind = $Matches.resourceKind
    $row.resourceName = $Matches.resourceName                    
    
    $resourceTable.Rows.Add($row)
    <#
    if(!$resourceRegex) {
        return 
    } else {
        return
    }
    #>

    return , @($resourceTable)
}

[Object]$ha = $null
foreach ($vm in $vms) {
    $ha += resourceKind -resourceId $vm.Id 
}                                                    

[Object]$ha = $null
foreach($nic in $nics) {
    $ha += resourceKind -resourceId $nic.Id
}