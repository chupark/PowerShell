$loadedData = Get-Content -Raw .\AzureServiceTag\ServiceTags_Public_20190722.json | ConvertFrom-Json
$koreaData = Select-Object $loadedData.values.name -match ".Korea"


$loadedData | $loadedData.values.name -match ".Korea"