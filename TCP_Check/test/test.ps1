$tcpClient = New-Object System.Net.Sockets.TcpClient
$tcpClient.Connect("grafana.bmdevs.com", "3000")
$Text = "test"
[byte[]]$bytes = [text.Encoding]::Ascii.GetBytes($Text)
$clientStream = $tcpClient.GetStream()
$clientStream.Write($bytes,0,$bytes.Length)
$clientStream.Flush()
$clientStream.DataAvailable
[byte[]]$inStream = New-Object byte[] 22
$response = $clientStream.Read($inStream, 0, $inStream.count)
[Int]$response = $clientStream.Read($inStream, 0, $inStream.count)
[System.Text.Encoding]::ASCII.GetString($inStream[0..($response - 1)])

$tcpClient.Dispose()
$clientStream.Dispose()

$clientStream.Close()
$tcpClient.Close()