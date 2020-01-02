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
    $request.HttpMethod
    
    if ($request.HttpMethod.ToString() -match "POST") {
        $message = @{url=$request.Url} | ConvertTo-Json
        $response.ContentType = 'application/json'
    }
    Write-Host "end Post IF"

    if ($request.HttpMethod.ToString() -match "GET") {
        Write-Host "enter Get"
    # Break from loop if GET request sent to /end
        if ($request.Url -match '/end$') { 
            break 
        } else {
    
            # Split request URL to get command and options
            $requestvars = ([String]$request.Url).split("/");        
    
            # If a request is sent to http:// :8000/wmi
            if ($requestvars[3] -eq "wmi") {
            
                # Get the class name and server name from the URL and run get-WMIObject
                $result = get-WMIObject $requestvars[4] -computer $requestvars[5];
    
                # Convert the returned data to JSON and set the HTTP content type to JSON
                $message = $result | ConvertTo-Json; 
                $response.ContentType = 'application/json';
    
        } else {
    
                # If no matching subdirectory/route is found generate a 404 message
                $message = "This is not the page you're looking for.";
                $response.ContentType = 'text/html' ;
        }
    }
    # Convert the data to UTF8 bytes
    Write-Host "buffer"
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    
    # Set length of response
    $response.ContentLength64 = $buffer.length
    
    # Write response out and close
    Write-Host "output start"
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
    Write-Host "request end"
    }    
}
 
#Terminate the listener
$listener.Stop()