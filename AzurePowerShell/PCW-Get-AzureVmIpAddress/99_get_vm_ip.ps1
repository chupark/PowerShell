########################################################################
# Date : 2018-11-01
# Get VM's IP Address
# 
########################################################################
function PCW-Get-AzureVMPublicIP {
    Param ([String] $resourceGroup)
    $array = @()
    if($resourceGroup.Length -eq 0) {
        $pubIps = Get-AzureRmPublicIpAddress
        $ipconfigs = $pubips.IpConfiguration.id
        $vms = Get-AzureRmVM
        $nics = $vms.NetworkProfile
        $flag = $false
        $ip = ""
        ForEach ($vm in $vms) {
            $nicString = $vm.NetworkProfile.NetworkInterfaces.id
            $lastSlash = $nicString.LastIndexOf("/")
            $nic = $nicString.Substring($lastSlash + 1, $nicString.Length - $lastSlash - 1)

            ForEach ($ipconfigs in $pubIps) {
                $ipconfig = $ipconfigs.IpConfiguration.id
                $a = ( $ipconfig | Select-String "/networkInterfaces/" -AllMatches).Matches.Index
                $b = ( $ipconfig | Select-String "/ipConfigurations/" -AllMatches).Matches.Index
                $pubIpNIC = $ipconfig.Substring($a + 19, $b - $a - 19)
                #$ipconfigs.IpAddress
                $ip = $ipconfigs.IpAddress
                if ($nic -match $pubIpNIC) {
                    $ourObject = New-Object -TypeName psobject 
                    $ourObject | Add-Member -MemberType NoteProperty -Name VmName -Value $vm.Name
                    $ourObject | Add-Member -MemberType NoteProperty -Name PublicIP -Value $ip
                    $array += $ourObject
                    break;
                }
            }
        }
    } else {
        $pubIps = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup
        $ipconfigs = $pubips.IpConfiguration.id
        $vms = Get-AzureRmVM -ResourceGroupName $resourceGroup
        $nics = $vms.NetworkProfile
        $flag = $false
        $ip = ""
        ForEach ($vm in $vms) {
            $nicString = $vm.NetworkProfile.NetworkInterfaces.id
            $lastSlash = $nicString.LastIndexOf("/")
            $nic = $nicString.Substring($lastSlash + 1, $nicString.Length - $lastSlash - 1)

            ForEach ($ipconfigs in $pubIps) {
                $ipconfig = $ipconfigs.IpConfiguration.id
                $a = ( $ipconfig | Select-String "/networkInterfaces/" -AllMatches).Matches.Index
                $b = ( $ipconfig | Select-String "/ipConfigurations/" -AllMatches).Matches.Index
                $pubIpNIC = $ipconfig.Substring($a + 19, $b - $a - 19)
                #$ipconfigs.IpAddress
                $ip = $ipconfigs.IpAddress
                if ($nic -match $pubIpNIC) {
                    $ourObject = New-Object -TypeName psobject 
                    $ourObject | Add-Member -MemberType NoteProperty -Name VmName -Value $vm.Name
                    $ourObject | Add-Member -MemberType NoteProperty -Name PublicIP -Value $ip
                    $array += $ourObject
                    break;
                }
            }
        }
    }
    return $array
}

function PCW-Get-AzureVmPrivateIP {
    Param([String]$resourceGroup)
    if ($resourceGroup.Length -eq 0) {
        $vms = Get-AzureRmVm
        $nics = Get-AzureRmNetworkInterface
        $array = @()
        ForEach ($vm in $vms) {
            ForEach ($nic in $nics) {
                if ($vm.Id -match $nic.VirtualMachine.Id) {
                    $ourObject = New-Object -TypeName psobject 
                    $ourObject | Add-Member -MemberType NoteProperty -Name VmName -Value $vm.Name
                    $ourObject | Add-Member -MemberType NoteProperty -Name PrivateIP -Value $nic.IpConfigurations.PrivateIpAddress
                    $array += $ourObject
                }
            }
        }
    } else {
        $vms = Get-AzureRmVm -ResourceGroupName $resourceGroup
        $nics = Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroup
        $array = @()
        ForEach ($vm in $vms) {
            ForEach ($nic in $nics) {
                if ($vm.Id -match $nic.VirtualMachine.Id) {
                    $ourObject = New-Object -TypeName psobject 
                    $ourObject | Add-Member -MemberType NoteProperty -Name VmName -Value $vm.Name
                    $ourObject | Add-Member -MemberType NoteProperty -Name PrivateIP -Value $nic.IpConfigurations.PrivateIpAddress
                    $array += $ourObject
                }
            }
        }
    }
    return $array
}