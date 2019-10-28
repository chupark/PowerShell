Import-Module -Name D:\PowerShell\PowerShell\cidr\cidr.psm1 -Force
$cidr = getCidrCalculator
$cidr.setCidr("10.1.3.1/14")
$cidr.setStartToEndIP()
$cidr.getStartIP()
$cidr.getEndIP()
$cidr.getHostCount()