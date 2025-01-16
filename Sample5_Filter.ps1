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
$uri = "https://graph.microsoft.com/v1.0/users?`$filter=id eq '$userId'"
$user = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$user.value | Select-Object -ExcludeProperty userPrincipalName, id
<#
businessPhones    : {}
displayName       : Morten Mynster Kristensen
givenName         : Morten
jobTitle          :
mail              :
mobilePhone       :
officeLocation    :
preferredLanguage : en
surname           : Mynster Kristensen
#>

$uri = "https://graph.microsoft.com/v1.0/groups"

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

$uri = "https://graph.microsoft.com/v1.0/groups?`$filter=(mailEnabled eq false and securityEnabled eq true)"
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

$uri = "https://graph.microsoft.com/v1.0/users?`$filter=startswith(userPrincipalName, 'morten')"
$usersStartWith = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeaders
$usersStartWith.value | Select-Object -ExcludeProperty userPrincipalName, id
<#
businessPhones    : {}
displayName       : Morten Mynster Kristensen
givenName         : Morten
jobTitle          :
mail              :
mobilePhone       :
officeLocation    :
preferredLanguage : en
surname           : Mynster Kristensen
#>

# More examples of filters can be found here:
# https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#for-single-primitive-types-like-string-int-and-dates
# Note that all Syntaxes that ends with ** are Advanced filters and can be a bit tricky to use.