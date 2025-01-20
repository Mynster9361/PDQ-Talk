<#
.SYNOPSIS
    Demonstrates how to make an API call using the device code flow with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate a user interactively using the device code flow and then make an API call to retrieve the user's app role assignments.

.NOTES
    MS Docs on how to use Ms Graph API with device code flow:
    https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code

    MS Docs on how to list app role assignments:
    https://learn.microsoft.com/en-us/graph/api/user-list-approleassignments?view=graph-rest-1.0&tabs=http

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.EXAMPLE
    # Set environment variables for tenantId and clientId
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"

    # Run the script
    .\2.0_ApiCallDeviceCode.ps1

    # Follow the instructions to authenticate and retrieve the user's app role assignments.
#>

# Tenant ID and Client ID for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId1

# Request device code
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

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Make an API call to retrieve the user's app role assignments
$uri = "https://graph.microsoft.com/v1.0/me/appRoleAssignments"
$me = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

# Output the app role assignments, excluding certain properties
$me.value | Select-Object -ExcludeProperty id, principalId, resourceId