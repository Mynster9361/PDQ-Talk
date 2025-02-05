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
# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"


# https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http#application-properties
# Example filter: Retrieve applications with redirect URIs starting with 'http://localhost'
$uri = "$graphApiUri/applications?`$filter=web/redirectUris/any(p:startswith(p, 'http://localhost'))&`$count=true"
$groupsWithLocalHostUrl = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groupsWithLocalHostUrl.value | select-object displayname, @{Name="redirectUris"; Expression={$_.web.redirectUris}}


# Example filter: Retrieve applications with redirect URIs that does NOT start with 'http://localhost'
$uri = "$graphApiUri/applications?`$filter=NOT web/redirectUris/any(p:startswith(p, 'http://localhost'))&`$count=true"
$applications = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$applications.value | Select-Object displayName, appId

# Example search and filter: Retrieve groups with display name or mail containing 'Talk', and filter by mailEnabled and securityEnabled properties
$uri = "$graphApiUri/groups?`$search=`"displayName:Talk`" OR `"mail:Talk`"&`$filter=(mailEnabled eq false and securityEnabled eq true)&`$count=true"
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id

# Example filter: Retrieve groups created within the last 7 days
$uri = "$graphApiUri/groups?`$filter=createdDateTime ge $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true"
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object displayName, createdDateTime

# Example filter: Retrieve users with job title 'Developer' and department 'Engineering'
$uri = "$graphApiUri/users?`$filter=jobTitle eq 'Developer' and department eq 'Engineering'&`$count=true&`$select=displayName, jobTitle, department"
$users = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$users.value

#! I do not have any devices in my tenant so this will not return any results
# Example filter: Retrieve devices with operating system 'Windows' and last sign-in within the last 30 days
$uri = "$graphApiUri/devices?`$filter=operatingSystem eq 'Windows' and lastSignInDateTime ge $((Get-Date).AddDays(-30).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true"
$devices = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$devices.value | Select-Object displayName, operatingSystem, lastSignInDateTime