<#
.SYNOPSIS
    Demonstrates how to make batch requests to the Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a client secret and then make batch requests to the Microsoft Graph API.
    It includes examples of retrieving users, user app role assignments, and groups with expanded owners.

.NOTES
    MS Docs on how to use batch requests with Microsoft Graph API:
    https://learn.microsoft.com/en-us/graph/json-batching

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
    .\8_BatchRequests.ps1

    # The script will output the results of the batch requests.
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

# URI for the batch endpoint
$uri = "https://graph.microsoft.com/v1.0/`$batch"

# Define the batch request body
$body = @{
    requests = @(
        @{
            id = "1"
            method = "GET"
            url = "/users/$userId/manager?`$select=id,displayName,jobTitle"
        },
        @{
            id = "2"
            method = "GET"
            url = "/users/$userId/appRoleAssignments"
        },
        @{
            id = "3"
            method = "GET"
            url = "/users/$userId/oauth2PermissionGrants"
        }
    )
}

# Make the batch request
$batchRequest = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body ($body | ConvertTo-Json)

# Debugging output
Write-Output "Batch request response:"
$batchRequest.responses | ForEach-Object {
    Write-Output "Response ID: $($_.id)"
    Write-Output "Status: $($_.status)"
    Write-Output "Body: $($_.body | ConvertTo-Json -Depth 6)"
    Write-Output "----------------------------------------"
}

# Display each individual response
$batchRequest.responses | Where-Object { $_.id -eq "1" } | Select-Object -ExpandProperty body | Select-Object id,displayName,jobTitle
$($batchRequest.responses | Where-Object { $_.id -eq "2" } | Select-Object -ExpandProperty body).value
$($batchRequest.responses | Where-Object { $_.id -eq "3" } | Select-Object -ExpandProperty body).value