<#
.SYNOPSIS
    Demonstrates how to make an API call using a client secret with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret and then make an API call to retrieve a user's app role assignments.

.NOTES
    MS Docs on how to use Ms Graph API with client credentials flow:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow

    MS Docs on how to get a user:
    https://learn.microsoft.com/en-us/graph/api/user-get?view=graph-rest-1.0&tabs=http

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER clientSecret
    The client secret of the registered application.

.PARAMETER userId
    The ID of the user whose app role assignments you want to retrieve.

.EXAMPLE
    # Set environment variables for tenantId, clientId, clientSecret, and userId
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"
    $env:clientSecret = "your-client-secret"
    $env:userId = "user-id"

    # Run the script
    .\2.1_ApiCall_ClientSecret.ps1

    # The script will output the user's app role assignments.
#>

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId2
$clientSecret = $env:clientSecret
$userId = $env:userId

# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}

# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}

# Make an API call to retrieve the user's app role assignments
$uri = "https://graph.microsoft.com/v1.0/users/$userId/appRoleAssignments"
$appRoleAssignments = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

# Output the app role assignments, excluding certain properties
$appRoleAssignments.value | Select-Object -ExcludeProperty id, principalId, resourceId