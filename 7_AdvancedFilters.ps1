<#
.SYNOPSIS
    Demonstrates how to use advanced filters to retrieve data from the Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret and then make API calls to retrieve data using advanced filters.
    It includes examples of filtering applications based on redirect URIs and searching for groups based on display name or mail.

.NOTES
    MS Docs on how to use advanced filters with Microsoft Graph API:
    https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http#application-properties

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
    .\7_AdvancedFilters.ps1

    # The script will output the filtered data based on advanced filters.
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
    "ConsistencyLevel" = "eventual" # This header is needed when using advanced filters in Microsoft Graph
}

# Example filter: Retrieve applications with redirect URIs starting with 'http://localhost'
$uri = "https://graph.microsoft.com/v1.0/applications?`$filter=web/redirectUris/any(p:startswith(p, 'http://localhost'))&`$count=true"
$groupsWithLocalHostUrl = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groupsWithLocalHostUrl.value.web.redirectUris
<#
http://localhost:8080
#>

# Example search and filter: Retrieve groups with display name or mail containing 'Talk', and filter by mailEnabled and securityEnabled properties
$uri = "https://graph.microsoft.com/v1.0/groups?`$search=`"displayName:Talk`" OR `"mail:Talk`"&`$filter=(mailEnabled eq false and securityEnabled eq true)&`$count=true"
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id
