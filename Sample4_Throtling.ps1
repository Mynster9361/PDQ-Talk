# MS Docs about throttling:
# https://learn.microsoft.com/en-us/graph/throttling
# Service specific limits:
# https://learn.microsoft.com/en-us/graph/throttling-limits

# For the easiest way to replicate throttling, we are going to use clien secret authentication and the /Subscription endpoint
# GET Subscription List	40 requests per 20 seconds

# Using Sample1.1_AuthSecret.ps1
$secretFile = "C:\Users\Morten\Desktop\github\PDQ-Talk\secrets2.json"
$secrets = Get-Content -Path $secretFile | ConvertFrom-Json
# Client Secret for the MS Graph API
$tenantId = $secrets.tenantId
$clientId = $secrets.clientId
$clientSecret = $secrets.clientSecret

# Default Token Body
$tokenBody = @{
    Grant_Type = "client_credentials"
    Scope = "https://graph.microsoft.com/.default"
    Client_Id = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers 
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}
# https://learn.microsoft.com/en-us/graph/api/subscription-list?view=graph-rest-1.0&tabs=http
$uri = "https://graph.microsoft.com/v1.0/subscriptions"

# The following will return a 429 error after 40 requests in 20 seconds which is the limit for the /Subscription endpoint
$counter = 0
do {
    write-output $counter
    try {
        Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
        $counter++
    }
    catch {
        $Error[0]
        $Error[0].Exception.Response.Headers["Retry-After"]
        <#
Invoke-RestMethod: 
Line |
   3 |          Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
     |          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | 
{
  "error": {
    "code": "TooManyRequests",
    "message": "Too many requests from Identifier:0e3ac3ed-9ead-44b8-bb21-2b68cbbc6fd1\u002B347ef610-cda7-4476-83e5-b804ce1d9abb under category:throttle.aad.ags.subscriptionservice.tenant.app.list. Please try again later.",
    "innerError": {
      "date": "2025-01-15T22:54:55"
    }
  }
}
        #>
        break
    }
    
} while (
    $true
)


# This will make sure that if we hit the limit we will wait for the time specified in the Retry-After header and then try again
# The Retry-After header is in seconds so we will add 1 second to the delay to make sure we are not hitting the limit again
# The hastable shows it like this:
# Key                       Value
# Retry-After               {20}
do {
    $throtleState = $null
    try {
        Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
    }
    catch {
        # https://learn.microsoft.com/en-us/graph/throttling#what-happens-when-throttling-occurs
        # The above url mentions we have a way of knowing how long we should wait this comes down to ms but the Retry-After header is in seconds the hastable shows it like this:
        # Key                       Value
        # Retry-After               {20}
        # We will add 1 second to the delay to make sure we are not hitting the limit again
        if ($_.Exception.Response.StatusCode.Value__ -eq 429) {
            [int]$Delay = 15
            [int]$Delay = ([int]$_.Exception.Response.Headers["Retry-After"] + 1)
            Start-Sleep -Seconds $Delay
            $throtleState = $true
        
        }
        else {
            # If for some reason we get a different error we will throw it
            throw ($_)
        }
    }
    
} while ($throtleState -eq $true)