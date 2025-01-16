# Article on generating a self signed certificate (Should not be used in production environment use one from your own trusted CA)
# https://blog.admindroid.com/how-to-create-self-signed-certificate-using-powershell/
# Remember to upload the certificate to the app registration under Certificates & secrets

# Reddit post on how to create the JWT with certificate
# https://www.reddit.com/r/PowerShell/comments/10fkoq8/comment/j5zxtn7/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

# MS Docs on how to use Ms Graph API with certificate
# https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials

# To be honest if you need to use a certificate you should the msgraph module to handle the authentication for you as it is a bit more complex than using a secret or device code flow
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0
# But if you want to do it manually here is an example on how to do it

# Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientIdCert
$thumbPrint = $env:thumbPrint

$cert = Get-Item Cert:\CurrentUser\My\$thumbPrint

# Create base64 hash of certificate
$CertificateBase64Hash = [System.Convert]::ToBase64String($cert.GetCertHash())
function Get-JWTTimestamps {
    # Create JWT timestamp for expiration
    $StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
    $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
    $JWTExpiration = [math]::Round($JWTExpirationTimeSpan, 0)
    # Create JWT validity start timestamp
    $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
    $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan, 0)
    return @{
        JWTExpiration = $JWTExpiration
        NotBefore = $NotBefore
    }
}

# Example usage
$timestamps = Get-JWTTimestamps
$JWTExpiration = $timestamps.JWTExpiration
$NotBefore = $timestamps.NotBefore

# Create JWT header
$JWTHeader = @{
    alg = "RS256"
    typ = "JWT"
    # Use the CertificateBase64Hash and replace/strip to match web encoding of base64
    x5t = $CertificateBase64Hash -replace '\+', '-' -replace '/', '_' -replace '='
}

# Create JWT payload
$JWTPayLoad = @{
    # JWT ID: random guid
    jti = [guid]::NewGuid()
    # Issuer = your application
    iss = $clientId
    # JWT Subject
    sub = $clientId
    # What endpoint is allowed to use this JWT
    aud = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    # Expiration timestamp
    exp = $timestamps.JWTExpiration
    # Not to be used before
    nbf = $timestamps.NotBefore
}

# Convert header and payload to base64
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)

$JWTPayLoadToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)

# Join header and Payload with "." to create a valid (unsigned) JWT
$JWT = $EncodedHeader + "." + $EncodedPayload

# Get the private key object of your certificate
# $PrivateKey = $Certificate.PrivateKey
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

$token = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $JWT
    grant_type    = "client_credentials"
}

$token
