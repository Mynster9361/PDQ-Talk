<#
.SYNOPSIS
    Demonstrates how to use filters to retrieve specific data from the Microsoft Graph API.

.DESCRIPTION
    This script shows how to apply OData filters to API requests to retrieve only the data that meets certain criteria.
    It includes examples of filtering users based on their userPrincipalName.

.NOTES
    MS Docs on how to use filters with Microsoft Graph API:
    https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#for-single-primitive-types-like-string-int-and-dates

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
    .\5_Filter.ps1

    # The script will output the filtered user data.
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

# More examples of filters can be found here:
# https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#for-single-primitive-types-like-string-int-and-dates
# Note that all syntaxes that end with ** are advanced filters and can be a bit tricky to use.

# Example filter: Retrieve users whose userPrincipalName starts with 'morten'
$uri = "https://graph.microsoft.com/v1.0/users?`$filter=startswith(userPrincipalName, 'morten')"
$usersStartWith = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$usersStartWith.value | Select-Object -ExcludeProperty userPrincipalName, id



$date = (Get-Date).AddMonths(3).ToString("yyyy-MM-ddT00:00:00.000Z")
$uri = "https://graph.microsoft.com/v1.0/users?`$filter=userType eq 'Guest' AND externalUserState eq 'PendingAcceptance' AND createdDateTime le $date&`$expand=memberOf"
$guestUsers = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$guestUsers.value | Select-Object -ExcludeProperty userPrincipalName, id,mail

$uri = "https://graph.microsoft.com/v1.0/groups?`$filter=(mailEnabled eq false and securityEnabled eq true)"
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id


$uri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$count=true&`$select=displayName,appId,id,preferredSingleSignOnMode,publisherName,homepage,appOwnerOrganizationId,accountEnabled,tags,applicationTemplateId,servicePrincipalType,createdDateTime,keyCredentials,servicePrincipalNames,preferredTokenSigningKeyThumbprint&`$search=""displayName:PDQ""&`$filter=tags/any(x:x eq 'WindowsAzureActiveDirectoryIntegratedApp') and accountEnabled eq true"
$servicePrincipals = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$servicePrincipals.value | Select-Object -ExcludeProperty id,appId,servicePrincipalNames