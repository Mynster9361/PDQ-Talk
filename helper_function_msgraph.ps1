function Get-GraphApiToken {
    param (
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    # Default Token Body
    $tokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        Client_Id     = $ClientId
        Client_Secret = $ClientSecret
    }

    # Request a Token
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

    # Return the token and headers
    return @{
        AccessToken = $tokenResponse.access_token
        Headers = @{
            "Authorization" = "Bearer $($tokenResponse.access_token)"
            "Content-type" = "application/json"
            "ConsistencyLevel" = "eventual" # This header is needed when using advanced filters in Microsoft Graph
        }
    }
}


function Invoke-GraphApiRequest {
    param (
        [string]$Uri,
        [hashtable]$Headers,
        [string]$Method = "Get",
        [object]$Body = $null,
        [switch]$Recursive
    )

    # Create an array to store the results if recursive is enabled
    if ($Recursive) {
        [System.Collections.Generic.List[System.Object]] $allResults = @()
    }

    do {
        $throttleState = $null
        try {
            if ($Body) {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body ($Body | ConvertTo-Json)
            } else {
                $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
            }

            # If recursive, add the results to the array
            if ($Recursive) {
                $allResults.AddRange($response.value)
            } else {
                return $response
            }

            # Check if there is a next page
            if ($response.'@odata.nextLink') {
                $Uri = $response.'@odata.nextLink'
            } else {
                $Uri = $null
            }
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.Value__
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue

            switch ($statusCode) {
                400 { # Bad Request
                    Write-Error "Bad Request Error: $($errorResponse.error.message)"
                    Write-Error "Error Code: $($errorResponse.error.code)"
                    Write-Error "Request ID: $($errorResponse.error.innerError.'request-id')"
                    Write-Error "Client Request ID: $($errorResponse.error.innerError.'client-request-id')"
                    throw "Bad Request: $($errorResponse.error.message)"
                }
                401 { # Unauthorized
                    Write-Error "Unauthorized: Check your access token and permissions."
                    throw "$statusCode Unauthorized: Check your access token and permissions."
                }
                402 { # Payment Required
                    Write-Error "Payment Required: The payment requirements for the API haven't been met."
                    throw "$statusCode Payment Required: The payment requirements for the API haven't been met."
                }
                403 { # Forbidden
                    Write-Error "Forbidden: Access is denied to the requested resource. The user might not have enough permission or might not have a required license."
                    if ($errorResponse.error.message -like "*insufficient_claims*") {
                        Write-Warning "Conditional Access Policy may be blocking access. Check your Conditional Access settings."
                    }
                    throw "$statusCode Forbidden: Access is denied to the requested resource."
                }
                404 { # Not Found
                    Write-Error "Not Found: The requested resource doesn't exist."
                    throw "$statusCode Not Found: The requested resource doesn't exist."
                }
                405 { # Method Not Allowed
                    Write-Error "Method Not Allowed: The HTTP method in the request isn't allowed on the resource."
                    throw "$statusCode Method Not Allowed: The HTTP method in the request isn't allowed on the resource."
                }
                406 { # Not Acceptable
                    Write-Error "Not Acceptable: This service doesn't support the format requested in the Accept header."
                    throw "$statusCode Not Acceptable: This service doesn't support the format requested in the Accept header."
                }
                409 { # Conflict
                    Write-Error "Conflict: The current state conflicts with what the request expects."
                    throw "$statusCode Conflict: The current state conflicts with what the request expects."
                }
                410 { # Gone
                    Write-Error "Gone: The requested resource is no longer available at the server."
                    throw "$statusCode Gone: The requested resource is no longer available at the server."
                }
                411 { # Length Required
                    Write-Error "Length Required: A Content-Length header is required on the request."
                    throw "$statusCode Length Required: A Content-Length header is required on the request."
                }
                412 { # Precondition Failed
                    Write-Error "Precondition Failed: A precondition provided in the request doesn't match the resource's current state."
                    throw "$statusCode Precondition Failed: A precondition provided in the request doesn't match the resource's current state."
                }
                413 { # Request Entity Too Large
                    Write-Error "Request Entity Too Large: The request size exceeds the maximum limit."
                    throw "$statusCode Request Entity Too Large: The request size exceeds the maximum limit."
                }
                415 { # Unsupported Media Type
                    Write-Error "Unsupported Media Type: The content type of the request is a format that isn't supported by the service."
                    throw "$statusCode Unsupported Media Type: The content type of the request is a format that isn't supported by the service."
                }
                416 { # Requested Range Not Satisfiable
                    Write-Error "Requested Range Not Satisfiable: The specified byte range is invalid or unavailable."
                    throw "$statusCode Requested Range Not Satisfiable: The specified byte range is invalid or unavailable."
                }
                422 { # Unprocessable Entity
                    Write-Error "Unprocessable Entity: Can't process the request because it is semantically incorrect."
                    throw "$statusCode Unprocessable Entity: Can't process the request because it is semantically incorrect."
                }
                423 { # Locked
                    Write-Error "Locked: The resource that is being accessed is locked."
                    throw "$statusCode Locked: The resource that is being accessed is locked."
                }
                429 { # Too Many Requests
                    [int]$Delay = ([int]$_.Exception.Response.Headers["Retry-After"] + 1)
                    Write-Warning "Throttling detected. Waiting for $Delay seconds before retrying..."
                    Start-Sleep -Seconds $Delay
                    $throttleState = $true
                }
                500 { # Internal Server Error
                    Write-Error "Internal Server Error: There was an internal server error while processing the request."
                    throw "$statusCode Internal Server Error: There was an internal server error while processing the request."
                }
                501 { # Not Implemented
                    Write-Error "Not Implemented: The requested feature isn't implemented."
                    throw "$statusCode Not Implemented: The requested feature isn't implemented."
                }
                503 { # Service Unavailable
                    Write-Error "Service Unavailable: The service is temporarily unavailable for maintenance or is overloaded. Retry after a delay."
                    throw "$statusCode Service Unavailable: The service is temporarily unavailable for maintenance or is overloaded."
                }
                504 { # Gateway Timeout
                    Write-Error "Gateway Timeout: The server, while acting as a proxy, didn't receive a timely response from the upstream server."
                    throw "$statusCode Gateway Timeout: The server, while acting as a proxy, didn't receive a timely response from the upstream server."
                }
                507 { # Insufficient Storage
                    Write-Error "Insufficient Storage: The maximum storage quota has been reached."
                    throw "$statusCode Insufficient Storage: The maximum storage quota has been reached."
                }
                509 { # Bandwidth Limit Exceeded
                    Write-Error "Bandwidth Limit Exceeded: Your app has been throttled for exceeding the maximum bandwidth cap. Retry after a delay."
                    throw "$statusCode Bandwidth Limit Exceeded: Your app has been throttled for exceeding the maximum bandwidth cap."
                }
                default {
                    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
                    throw $_
                }
            }
        }
    } while ($throttleState -eq $true -or ($Recursive -and $Uri))

    # Return all results if recursive is enabled
    if ($Recursive) {
        return $allResults
    }
}

