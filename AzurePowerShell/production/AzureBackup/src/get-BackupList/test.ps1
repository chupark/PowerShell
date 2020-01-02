$vms = Get-AzVM 


$vms | Where-Object {$_.Tags.Values -eq "snapshot"} | Export-Csv "tag_snapshot.csv"