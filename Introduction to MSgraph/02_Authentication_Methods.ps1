#region Authentication
# Reference Docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/connect-mggraph?view=graph-powershell-1.0
$tenantId = $env:tsttenantId
# Interactive authentication (best for demos)
Connect-MgGraph -Scopes "User.Read.All" -TenantId $tenantId


# Automation authentication (for automation)
$appId = $env:tstAppId
$secret = $env:tstClientSecret

# Client secret auth (for automation)
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $secret -AsPlainText -Force)
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential


# Certificate-based auth (for automation)
$cert = New-SelfSignedCertificate -Subject CN=PSWednessday -CertStoreLocation 'Cert:\CurrentUser\My'
Export-Certificate -Cert $cert -FilePath PSWednessday.crt
Connect-MgGraph -ClientId $appId -TenantId $tenantId -CertificateName $cert.Subject

#endregion
