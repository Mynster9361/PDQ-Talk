<#
.SYNOPSIS
    Demonstrates how to authenticate using a client secret with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret.
    It requests an access token using the client credentials flow.

.NOTES
    MS Docs on how to use Ms Graph API with client credentials flow:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER clientSecret
    The client secret of the registered application.

.EXAMPLE
    # Set environment variables for tenantId, clientId, and clientSecret
    $env:tenantId = "your-tenant-id"
    $env:clientIdSecret = "your-client-id"
    $env:clientSecret = "your-client-secret"

    # Run the script
    .\1.1_AuthSecret.ps1

    # The script will output the access token.
#>

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId2
$clientSecret = $env:clientSecret

# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}

# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Output the token
$tokenResponse