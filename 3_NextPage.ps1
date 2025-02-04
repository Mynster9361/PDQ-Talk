<#
.SYNOPSIS
    Demonstrates how to handle pagination when retrieving data from the Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret and then make an API call to retrieve a user's app role assignments.
    It handles pagination to retrieve all pages of data.

.NOTES
    MS Docs on how to use Ms Graph API with client credentials flow:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow

    MS Docs on how to list app role assignments:
    https://learn.microsoft.com/en-us/graph/api/user-list-approleassignments?view=graph-rest-1.0&tabs=http

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
    .\3_NextPage.ps1

    # The script will output the user's app role assignments, handling pagination to retrieve all pages of data.
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
$uri = "https://graph.microsoft.com/v1.0/users/$userId/appRoleAssignments?`$top=1"
$appRoleAssignments = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

# Create an array to store the results
[System.Collections.Generic.List[System.Object]] $allAppRoleAssignments = @()
$allAppRoleAssignments.addrange($appRoleAssignments.value)

# Handle pagination to retrieve all pages of data
do {
    # Check if there is a next page
    if ($appRoleAssignments.'@odata.nextLink') {
        $uri = $appRoleAssignments.'@odata.nextLink'
        # Get the next page
        $appRoleAssignments = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
        # Add the results to the array
        $allAppRoleAssignments.addrange($appRoleAssignments.value)
    }
}
while ($appRoleAssignments.'@odata.nextLink')

# Display the results
$allAppRoleAssignments | Select-Object -ExcludeProperty id, principalId, resourceId