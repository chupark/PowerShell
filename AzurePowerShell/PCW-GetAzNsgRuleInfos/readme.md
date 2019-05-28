# Azure 로그인 & 구독 선택

<br>

## Required
    
````yaml
Import AzureRM Module
````
<br>

## Usage

````yaml
[Default Usage]
Import-Module <some-where-your-location>\99_login_azure.ps1
PCW-Get-AzureLogin

Your Subscriptions are
1. [hello subscription]
2. [world subscription]

Select Your Subscription for use
2


Account          : your@mail.com
SubscriptionName : Visual Studio Enterprise – MPN
SubscriptionId   : <your-subscription-id>
TenantId         : <your-tenant-id>
Environment      : AzureCloud

````

<br>

## Optional Parameters
### -resourceGroupName
```yaml
Type: String
Aliases: 

Required: False
```
