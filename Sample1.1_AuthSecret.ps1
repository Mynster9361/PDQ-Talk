# MS Docs on how to use Ms Graph API with client secret
# https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow

# Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientIdSecret
$clientSecret = $env:clientSecret

# Default Token Body
$tokenBody = @{
    Grant_Type = "client_credentials"
    Scope = "https://graph.microsoft.com/.default"
    Client_Id = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Output the token
$tokenResponse