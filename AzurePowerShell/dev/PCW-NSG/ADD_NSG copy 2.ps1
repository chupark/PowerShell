$exception_NSG = @("WAF-ext-nsg", "WAF-mgmt-nsg")

$nsgLists = Get-AzNetworkSecurityGroup
foreach ($nsg in $nsgLists) {
    if($exception_NSG = @("WAF-ext-nsg", "WAF-mgmt-nsg") | Where-Object {$_-eq $nsg.Name}) {
        Continue
    }
    $nsg | 
    Add-AzNetworkSecurityRuleConfig -Name "Allow_Server_AccessControl" `
                                    -Description "2919-07-23 / chiwoo" `
                                    -SourcePortRange "*" `
                                    -Access Allow `
                                    -Protocol Tcp `
                                    -Direction Inbound `
                                    -Priority 400 `
                                    -SourceAddressPrefix "10.0.100.20/32", "10.0.100.30/32" `
                                    -DestinationAddressPrefix "VirtualNetwork" `
                                    -DestinationPortRange "22", "3389"
    $nsg | Set-AzNetworkSecurityGroup
    Write-Host $nsg.Name
}