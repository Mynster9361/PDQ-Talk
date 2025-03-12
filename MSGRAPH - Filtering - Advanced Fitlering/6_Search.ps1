<#
.SYNOPSIS
    Demonstrates how to use the search functionality to find data in the Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret and then make an API call to search for users in the Microsoft Graph API.

.NOTES
    MS Docs on how to use search with Microsoft Graph API:
    https://learn.microsoft.com/en-us/graph/search-query-parameter

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER clientSecret
    The client secret of the registered application.

.EXAMPLE
    # Set environment variables for tenantId, clientId, and clientSecret
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"
    $env:clientSecret = "your-client-secret"

    # Run the script
    .\6_Search.ps1

    # The script will output the search results for users.
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

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}
# https://learn.microsoft.com/en-us/graph/api/group-get?view=graph-rest-1.0&tabs=http
$uri = "https://graph.microsoft.com/v1.0/groups?`$search=`"displayName:PDQ`" OR `"mail:Talk`""
$authHeaders += @{ConsistencyLevel = "eventual"}
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id

$uri = 'https://graph.microsoft.com/v1.0/groups?$search="description:PDQTESTTALK" AND ("displayName:PDQ-TALK")&$count=true'
$authHeaders += @{ConsistencyLevel = "eventual"}
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id