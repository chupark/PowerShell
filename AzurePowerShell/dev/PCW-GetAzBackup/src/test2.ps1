$location = (Get-Location).Path
Import-module -Name "$location\src\library\tools.psm1"

# 해당 column을 가진 table 만들기
$col=@("ResourceGroupName", "Name", "Location", "VmSize", "OsType", "NIC")
$table = MakeTable "backupReport" $col

# 해당 리소스 그룹에 있는 VM을 찾고 싶다.
$resourceGroupName = "D-IF-RG"
$vvv=Get-AzVm -ResourceGroupName "D-IF-RG"
# VM 읽기
$vms = Get-AzVM

#반복문 시작
foreach ($vm in $vms) {
    $osType = ""
    if ($vm.ResourceGroupName -eq $resourceGroupName) {
        if ($vm.OSProfile.WindowsConfiguration){
            $osType = "Windows"
        } else {
            $osType = "Linux"
        }
        # 원하는 데이터를 한 줄로 보여주고 싶기 때문에 다시 테이블로 쑤셔넣어야 한다..
        # 이런 식으로 코드를 짜면 쓸데없는 노가다가 필요하다..
        $aa = $vm.NetworkProfile.NetworkInterfaces.Id -match "/Microsoft.Network/networkInterfaces/(?<nicName>.+)"
        $row=$table.NewRow()
        $row.ResourceGroupName = $vm.ResourceGroupName
        $row.Name = $vm.Name
        $row.Location = $vm.Location
        $row.VmSize = $vm.HardwareProfile.VmSize
        $row.OsType = $osType
        $row.NIC = $Matches.nicName
        $table.Rows.Add($row)
    }
}

$nics = Get-AzNetworkInterface

foreach ($vm in $vms) {
    $zz = $vm.NetworkProfile.NetworkInterfaces.Id -match "/Microsoft.Network/networkInterfaces/(?<nicName>.+)"
    $vmNicName = $Matches.nicName
    $nics | Where-Object{$_.Name -eq $vmNicName}
}

# 해당 리소스 그룹에 있는 VM을 찾고 싶다.
$resourceGroupName = "D-IF-RG"
$vms | Where-Object {$_.ResourceGroupName -eq "D-IF-RG"}

# VM 읽기
$vms = Get-AzVM
$nics = Get-AzNetworkInterface
$myVMs = $vms | Where-Object {$_.ResourceGroupName -eq "D-IF-RG"}
foreach ($vm in $myVMs) {
    $myNic = $nics | Where-Object{$_.Id -eq $vm.NetworkProfile.NetworkInterfaces.Id}
    Write-Host VM : $vm.Name  //  PrivateIP : $myNic.IpConfigurations.PrivateIpAddress
}