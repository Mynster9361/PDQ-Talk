$secretFile = "C:\Users\Morten\Desktop\github\PDQ-Talk\secrets1.json"
$secrets = Get-Content -Path $secretFile | ConvertFrom-Json

# Client Secret for the MS Graph API
$tenantId = $secrets.tenantId
$clientId = $secrets.clientId

# Interactive login for the MS Graph API
$response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -Method POST -Body @{
    client_id     = $clientId
    scope         = "user.read"
} 
# Extract device code, user code and verification uri
$deviceCode = $response.device_code
$userCode = $response.user_code
$verificationUrl = $response.verification_uri

# Open authentication url in default browser
Start-Process $verificationUrl
# Display instructions to the user
Write-Host "Please type in the following code: $userCode"

# Once the user has authenticated, request a token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "urn:ietf:params:oauth:grant-type:device_code"
    device_code   = $deviceCode
}

# Setting up the authorization headers 
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}
# https://learn.microsoft.com/en-us/graph/api/user-list-approleassignments?view=graph-rest-1.0&tabs=http
$uri = "https://graph.microsoft.com/v1.0/me/appRoleAssignments"
$me = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

$me.value

