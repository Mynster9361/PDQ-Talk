# Documentation on advanced filters in Microsoft Graph and notation of where it is neccesary and where it is supported by default:
# https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http#support-for-filter-by-properties-of-microsoft-entra-id-directory-objects

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
    "ConsistencyLevel" = "eventual" # This header is needed when using advanced filters in Microsoft Graph
}
# https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http#application-properties
$uri = "https://graph.microsoft.com/v1.0/applications?`$filter=web/redirectUris/any(p:startswith(p, 'http://localhost'))&`$count=true"
$groupsWithLocalHostUrl = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groupsWithLocalHostUrl.value.web.redirectUris
<#
http://localhost:8080
#>

$uri = "https://graph.microsoft.com/v1.0/groups?`$search=`"displayName:Talk`" OR `"mail:Talk`"&`$filter=(mailEnabled eq false and securityEnabled eq true)&`$count=true"
$groups = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$groups.value | Select-Object -ExcludeProperty id
<#
deletedDateTime               :
classification                :
createdDateTime               : 16-01-2025 19:32:52
creationOptions               : {}
description                   :
displayName                   : PDQ-TALK
expirationDateTime            :
groupTypes                    : {}
isAssignableToRole            :
mail                          :
mailEnabled                   : False
mailNickname                  : cd525e9e-0
membershipRule                :
membershipRuleProcessingState :
onPremisesDomainName          :
onPremisesLastSyncDateTime    :
onPremisesNetBiosName         :
onPremisesSamAccountName      :
onPremisesSecurityIdentifier  :
onPremisesSyncEnabled         :
preferredDataLocation         :
preferredLanguage             :
proxyAddresses                : {}
renewedDateTime               : 16-01-2025 19:32:52
resourceBehaviorOptions       : {}
resourceProvisioningOptions   : {}
securityEnabled               : True
securityIdentifier            : S-1-12-1-3257614323-1195558534-501174918-2150161750
theme                         :
uniqueName                    :
visibility                    :
onPremisesProvisioningErrors  : {}
serviceProvisioningErrors     : {}
#>