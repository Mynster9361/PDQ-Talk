# Description: This script will make a call to Microsoft Graph API to get all users in the tenant.

# Using Sample1.1_AuthSecret.ps1
$secretFile = "C:\Users\Morten\Desktop\github\PDQ-Talk\secrets2.json"
$secrets = Get-Content -Path $secretFile | ConvertFrom-Json
# Client Secret for the MS Graph API
$tenantId = $secrets.tenantId
$clientId = $secrets.clientId
$clientSecret = $secrets.clientSecret

# Default Token Body
$tokenBody = @{
    Grant_Type = "client_credentials"
    Scope = "https://graph.microsoft.com/.default"
    Client_Id = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers 
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type" = "application/json"
}
# https://learn.microsoft.com/en-us/graph/api/user-get?view=graph-rest-1.0&tabs=http
$userId = $secrets.userId
$uri = "https://graph.microsoft.com/v1.0/users/$userId/appRoleAssignments"
$appRoleAssignments = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders

$appRoleAssignments.value | Select-Object -Property id, deletedDateTime, appRoleId, createdDateTime, principalDisplayName, principalType, resourceDisplayName