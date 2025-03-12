. .\helper_function_msgraph.ps1
# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId2
$clientSecret = $env:clientSecret

# Get the access token and headers
$auth = Get-GraphApiToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret
$authHeaders = $auth.Headers

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"

# Example filter: Retrieve applications with redirect URIs starting with 'http://localhost'
$uri = "$graphApiUri/applications?`$filter=web/redirectUris/any(p:startswith(p, 'http://localhost'))&`$count=true"
$applications = Invoke-GraphApiRequest -Uri $uri -Headers $authHeaders -Recursive
$applications | Select-Object displayName, appId, publisherDomain

# Example search and filter: Retrieve groups with display name or mail containing 'Talk', and filter by mailEnabled and securityEnabled properties
$uri = "$graphApiUri/groups?`$search=`"displayName:Talk`" OR `"mail:Talk`"&`$filter=(mailEnabled eq false and securityEnabled eq true)&`$count=true"
$groups = Invoke-GraphApiRequest -Uri $uri -Headers $authHeaders -Recursive
$groups | Select-Object -ExcludeProperty id

# Example filter: Retrieve groups created within the last 7 days
$uri = "$graphApiUri/groups?`$filter=createdDateTime ge $((Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ"))&`$count=true"
$groups = Invoke-GraphApiRequest -Uri $uri -Headers $authHeaders -Recursive
$groups | Select-Object displayName, createdDateTime

# Example filter: Retrieve users with job title 'Developer' and department 'Engineering'
$uri = "$graphApiUri/users?`$filter=jobTitle eq 'Developer' and department eq 'Engineering'&`$count=true&`$select=displayName, jobTitle, department"
$users = Invoke-GraphApiRequest -Uri $uri -Headers $authHeaders -Recursive
$users