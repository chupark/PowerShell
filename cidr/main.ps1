Import-Module -Name D:\PowerShell\study\cidr\cidr.psm1 -Force
## $bbb = getCidrCalculator
$bbb.setCidr("10.3.5.3/31")
$bbb.setStartToEndIP()
$bbb.getStartIP()
$bbb.getEndIP()
$bbb.getHostCount()

$a = 8

if($a -ge 8 -and $a -le 15) {
    Write-Host Ho
}