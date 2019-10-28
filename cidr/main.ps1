Import-Module -Name D:\PowerShell\PowerShell\cidr\cidr.psm1 -Force
$cidr = getCidrCalculator
$cidr.setCidr("10.0.0.1/30")
$cidr.setStartToEndIP()
$cidr.getStartIP()
$cidr.getEndIP()
$cidr.getHostCount()