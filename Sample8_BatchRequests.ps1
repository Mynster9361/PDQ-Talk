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

$uri = "https://graph.microsoft.com/v1.0/`$batch"
$body = @{
    requests = @(
        @{
            id = "1"
            method = "GET"
            url = "/users?`$filter=startswith(userPrincipalName, 'morten')"
        },
        @{
            id = "2"
            method = "GET"
            url = "/users/$($secrets.userId)/appRoleAssignments"
        },
        @{
            id = "3"
            method = "GET"
            url = "/groups?`$expand=owners"
        }
    )
}
$batchRequest = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body ($body | ConvertTo-Json)
($batchRequest.responses | Where-Object { $_.id -eq 1 }).body.value | Select-Object -ExcludeProperty id, userPrincipalName
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
($batchRequest.responses | Where-Object { $_.id -eq 2 }).body.value | Select-Object -ExcludeProperty id, principalId, resourceId
<#
deletedDateTime      :
appRoleId            : 00000000-0000-0000-0000-000000000000
createdDateTime      : 15-01-2025 20:33:26
principalDisplayName : Morten Mynster Kristensen
principalType        : User
resourceDisplayName  : PDQ-Talk

deletedDateTime      :
appRoleId            : 00000000-0000-0000-0000-000000000000
createdDateTime      : 15-01-2025 22:13:09
principalDisplayName : Morten Mynster Kristensen
principalType        : User
resourceDisplayName  : PDQ-Talk2
#>
($batchRequest.responses | Where-Object { $_.id -eq 3 }).body.value | Select-Object -ExcludeProperty id
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
owners                        : {@{@odata.type=#microsoft.graph.user; id=N/A; deletedDateTime=; accountEnabled=True; ageGroup=; businessPhones=System.Object[]; city=; co
                                mpanyName=; consentProvidedForMinor=; country=; createdDateTime=15-01-2025 20:16:27; creationType=; department=; displayName=test; employeeId=; employeeHireDate=; employe
                                eLeaveDateTime=; employeeType=; externalUserState=; externalUserStateChangeDateTime=; faxNumber=; givenName=test; isLicenseReconciliationNeeded=False; jobTitle=; legalAge
                                GroupClassification=; mail=; mailNickname=test; mobilePhone=; onPremisesDistinguishedName=; onPremisesDomainName=; onPremisesImmutableId=; onPremisesLastSyncDateTime=; on
                                PremisesSecurityIdentifier=; onPremisesSamAccountName=; onPremisesSyncEnabled=; onPremisesUserPrincipalName=; otherMails=System.Object[]; passwordPolicies=; officeLocatio
                                n=; postalCode=; preferredDataLocation=; preferredLanguage=; proxyAddresses=System.Object[]; refreshTokensValidFromDateTime=15-01-2025 20:16:27; imAddresses=System.Object
                                []; isResourceAccount=; showInAddressList=; securityIdentifier=S-1-12-1-3489439022-1147582277-1687198600-2622953893; signInSessionsValidFromDateTime=15-01-2025 20:16:27;
                                state=; streetAddress=; surname=test; usageLocation=; userPrincipalName=test@N/A.onmicrosoft.com; externalUserConvertedOn=; userType=Member; employeeOrgD
                                ata=; assignedLicenses=System.Object[]; assignedPlans=System.Object[]; authorizationInfo=; identities=System.Object[]; onPremisesProvisioningErrors=System.Object[]; passw
                                ordProfile=; onPremisesExtensionAttributes=; provisionedPlans=System.Object[]; serviceProvisioningErrors=System.Object[]}}
#>