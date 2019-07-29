$OutputEncoding = [System.Text.Encoding]::UTF8
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
            if ($request.Url -match '/$') { 
                $streamReader = [System.IO.StreamReader]::new($request.InputStream)
                $parsing = $streamReader.ReadToEnd() | ConvertFrom-json
                Write-Host "Event ID : " $parsing.Events.EventId 
                Write-Host "Affected VM :" $parsing.Events.Resources
                Write-Host "Start Time : " $parsing.Events.NotBefore
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
}
 
#Terminate the listener
$listener.Stop()