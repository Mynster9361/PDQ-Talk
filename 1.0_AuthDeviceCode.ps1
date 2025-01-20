<#
.SYNOPSIS
    Demonstrates how to authenticate using the device code flow with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate a user interactively using the device code flow.
    It retrieves a device code, prompts the user to authenticate, and then requests an access token.

.NOTES
    MS Docs on how to use Ms Graph API with device code flow:
    https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code

    Remember to enable "Allow public client flows" under Authentication - Advanced settings on the app registration
    otherwise you will get an error.

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.EXAMPLE
    # Set environment variables for tenantId and clientId
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"

    # Run the script
    .\1.0_AuthDeviceCode.ps1

    # Follow the instructions to authenticate and obtain an access token.
#>

# Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId1

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
Pause "Press Enter to continue..."

# Once the user has authenticated, request a token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "urn:ietf:params:oauth:grant-type:device_code"
    device_code   = $deviceCode
}
$tokenResponse