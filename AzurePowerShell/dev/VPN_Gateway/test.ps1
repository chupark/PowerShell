# 리소스 그룹 이름
$resourceGroupName = "zenithn-Network-Test"
# vpnGateway 정보
$vpnGatewayName = "R-VpnGw"
#localNetworkGateway 정보
$localGatewayName = "Carrotins-IDC"
# connection 정보
$connectionName = "S2S_R-VNet_to_IDC"
$connectionLocation= "Korea South"
$sharedKey = "carrot2azure"

# VPN Gateway 정보
$vnet1gw = Get-AzVirtualNetworkGateway -Name $vpnGatewayName  -ResourceGroupName $resourceGroupName
# Local Network Gateway 정보
$lng6 = Get-AzLocalNetworkGateway  -Name $localGatewayName -ResourceGroupName $resourceGroupName

# Phase1, Phase2 설정
$ipsecpolicy6 = New-AzIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA256 -DhGroup DHGroup2 -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup None -SALifeTimeSeconds 28800 # Phase 2 : Ipsec

# 새로운 Connection 생성
New-AzVirtualNetworkGatewayConnection -Name $connectionName -ResourceGroupName zenithn-Network-Test -VirtualNetworkGateway1 $vnet1gw -LocalNetworkGateway2 $lng6 -Location $connectionLocation -ConnectionType IPsec -IpsecPolicies $ipsecpolicy6 -SharedKey $sharedKey -UsePolicyBasedTrafficSelectors $true

# New-AzIpsecPolicy로 Connection을 만들었을 경우 IpsecPolicies를 확인할 수 있음
# Portal 에서 만들면 확인 불가.
$conn = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $resourceGroupName -Name $connectionName
$conn.IpsecPolicies