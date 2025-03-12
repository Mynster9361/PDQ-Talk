<#
.SYNOPSIS
    Demonstrates how to authenticate using a certificate with Microsoft Graph API.

.DESCRIPTION
    This script shows how to authenticate an application using a certificate.
    It creates a JWT (JSON Web Token) signed with the certificate's private key and requests an access token using the client credentials flow.

.NOTES
    MS Docs on how to use Ms Graph API with certificate-based authentication:
    https://learn.microsoft.com/en-us/azure/active-directory/develop/active-directory-certificate-credentials

.PARAMETER tenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER clientId
    The client ID of the registered application.

.PARAMETER thumbPrint
    The thumbprint of the certificate to use for authentication.

.EXAMPLE
    # Set environment variables for tenantId, clientId, and thumbPrint
    $env:tenantId = "your-tenant-id"
    $env:clientId = "your-client-id"
    $env:thumbPrint = "your-certificate-thumbprint"

    # Run the script
    .\1.2_AuthCertificate.ps1

    # The script will output the access token.
#>

# Tenant ID, Client ID, and Certificate Thumbprint for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId3
$thumbPrint = $env:thumbPrint

# Get the certificate from the certificate store
$cert = Get-Item Cert:\CurrentUser\My\$thumbPrint

# Create JWT header
$JWTHeader = @{
    alg = "RS256"
    typ = "JWT"
    x5t = [System.Convert]::ToBase64String($cert.GetCertHash())
}

# Create JWT payload
$JWTPayload = @{
    aud = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    iss = $clientId
    sub = $clientId
    jti = [System.Guid]::NewGuid().ToString()
    nbf = [math]::Round((Get-Date).ToUniversalTime().Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
    exp = [math]::Round((Get-Date).ToUniversalTime().AddMinutes(10).Subtract((Get-Date "1970-01-01T00:00:00Z").ToUniversalTime()).TotalSeconds)
}

# Encode JWT header and payload
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json -Compress))
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte) -replace '\+', '-' -replace '/', '_' -replace '='

$JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json -Compress))
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte) -replace '\+', '-' -replace '/', '_' -replace '='

# Join header and Payload with "." to create a valid (unsigned) JWT
$JWT = $EncodedHeader + "." + $EncodedPayload

# Get the private key object of your certificate
$PrivateKey = ([System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert))

# Define RSA signature and hashing algorithm
$RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
$HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256

# Create a signature of the JWT
$Signature = [Convert]::ToBase64String(
    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT), $HashAlgorithm, $RSAPadding)
) -replace '\+', '-' -replace '/', '_' -replace '='

# Join the signature to the JWT with "."
$JWT = $JWT + "." + $Signature

# Request a token
$token = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $JWT
    grant_type    = "client_credentials"
}

# Output the token
$token