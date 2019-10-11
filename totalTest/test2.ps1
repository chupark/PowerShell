$a = "39.7.48.7 - - [04/Sep/2019:15:11:24 +0900] "
$a -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"

[Array]$aclog
foreach ($aa in $accesslog) {
    $aa -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    $aclog += $Matches.Values
}