$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/') 
$listener.Start()
'Listening ...'

# Run until you send a GET request to /end
while ($true) {
    try {
        $context = $listener.GetContext() 
        # Capture the details about the request
        $request = $context.Request
        # Setup a place to deliver a response
        $response = $context.Response
        $message = '{"end" : "end"}'
        foreach ($headers in $request.Headers) {
            Write-Host Header : $headers // Value : $request.Headers.GetValues($headers)
        }
        Write-Host Auth : $listener.AuthenticationSchemes.value__
        $request.HttpMethod.ToString()
        $streamReader = [System.IO.StreamReader]::new($request.InputStream)
        $parsing = $streamReader.ReadToEnd() | ConvertFrom-json
        Write-Host $parsing
    } catch {
        Write-Host "Error"
    } finally {
        # Convert the data to UTF8 bytes
        Write-Host $message
        [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
            
        # Set length of response
        $response.ContentLength64 = $buffer.length

        # Write response out and close
        $output = $response.OutputStream
        $output.Write($buffer, 0, $buffer.length)
        $output.Close()
    }
    $listener.Stop()
    break;
}