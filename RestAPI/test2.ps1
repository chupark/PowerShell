$OutputEncoding = [System.Text.Encoding]::UTF8
# Create a listener on port 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/') 
$listener.Start()
'Listening ...'

# Run until you send a GET request to /end
while ($true) {
    $context = $listener.GetContext() 
    # Capture the details about the request
    $request = $context.Request
    # Setup a place to deliver a response
    $response = $context.Response
    
    if ($request.HttpMethod.ToString() -match "POST") {
        $streamReader = [System.IO.StreamReader]::new($request.InputStream)
        $message = $streamReader.ReadToEnd()
        $parsing = $message | ConvertFrom-json
        Write-Host "Event ID : " $parsing.Events.EventId 
        Write-Host "Affected VM :" $parsing.Events.Resources
        Write-Host "Start Time : " $parsing.Events.NotBefore
        
        $response.ContentType = 'application/json'
        if ($request.Url -match '/end$') { 
            break 
        }
    }
    
    if ($request.HttpMethod.ToString() -match "GET") {
    # Break from loop if GET request sent to /end
        if ($request.Url -match '/end$') { 
            break 
        } else {    
            # If no matching subdirectory/route is found generate a 404 message
            $message = "This is not the page you're looking for.";
            $response.ContentType = 'text/html' ;
        }
    }
    # Convert the data to UTF8 bytes
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    
    # Set length of response
    $response.ContentLength64 = $buffer.length
    
    # Write response out and close
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
}
 
#Terminate the listener
$listener.Stop()