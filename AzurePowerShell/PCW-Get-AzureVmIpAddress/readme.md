# Azure 가상머신의 IP 받아오기

<br>

## PCW-Get-AzureVMPublicIP[-resourceGroupName] <String>
    
````yaml
Required
Import AzureRM Module
````

## Usage

````yaml
Import-Module <some-where-your-location>\99_get_vm_ip.ps1
$ips = PCW-AzureVMPublicIP <your-ResourceGroup>
$ips
VmName                         PublicIP
----                           ----- 
VM-ABC                         123.123.123.123
VM-DEF                         234.234.234.234


$ips = PCW-AzureVMPrivateIP <your-ResourceGroup>
$ips
VmName                         PrivateIP
----                           ----- 
VM-ABC                         10.0.0.5
VM-DEF                         10.0.0.6
````

<br>

## Parameters
### -resourceGroupName
```yaml
Type: String
Aliases: 

Required: False
```
