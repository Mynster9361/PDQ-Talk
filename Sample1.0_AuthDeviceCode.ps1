# MS Docs on how to use Ms Graph API with device code flow
# https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code
# Remember to enable "Allow public client flows" under Authentication - Advanced settings on the app registration otherwise you will get an error

# Import secrets from a json file

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
$tokenResponse



