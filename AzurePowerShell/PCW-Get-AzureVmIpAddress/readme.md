# Azure 가상머신의 IP 받아오기

<br>

## Required
    
````yaml
Import AzureRM Module
````
<br>

## Usage

````yaml
Import-Module <some-where-your-location>\99_get_vm_ip.ps1
$ips = PCW-AzureVMPublicIP <your-ResourceGroup> | ft
$ips
ResourceGroup   VmName      PublicIP          Os          Location
----            -----       -----             -----       ----- 
MyRG01          VM-ABC      123.123.123.123   windows     eastus
MyRG01          VM-DEF      234.234.234.234   linux       eastus


$ips = PCW-AzureVMPrivateIP <your-ResourceGroup> | ft
$ips
ResourceGroup   VmName      PrivateIP         Os          Location
----            -----       -----             -----       ----- 
MyRG01          VM-ABC      10.0.2.5          windows     eastus
MyRG01          VM-DEF      10.0.2.6          linux       eastus
````

<br>

## Parameters
### -resourceGroupName
```yaml
Type: String
Aliases: 

Required: False
```
