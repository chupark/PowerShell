$OutputEncoding = [System.Text.Encoding]::UTF8
# https://docs.microsoft.com/ko-kr/dotnet/api/system.net.httplistener.authenticationschemes?view=netframework-4.8
# Create a listener on port 8000
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
        if ($request.HttpMethod.ToString() -match "POST") {
            # Get-Headers
            foreach ($headers in $request.Headers) {
                Write-Host Header : $headers // Value : $request.Headers.GetValues($headers)
            }
            $listener.AuthenticationSchemes

            

            if ($request.Url -match '/$') { 
                $streamReader = [System.IO.StreamReader]::new($request.InputStream)
                $parsing = $streamReader.ReadToEnd() | ConvertFrom-json
                Write-Host $parsing
                Write-Host "Event ID : " $parsing.Events.EventId 
                $response.ContentType = 'application/json'
                $message = '{"200" : "ok"}' 
            } elseif ($request.Url -match '/end$') {
                break
            } else {
                $message = '{"404" : "no pages"}'
                Write-Host "here"
            }
        } else {
            $message = '{"404" : "no pages"}'
        }
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
}
 
