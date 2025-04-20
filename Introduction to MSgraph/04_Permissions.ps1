#region Find permissions needed for a command
# Reference Docs: https://learn.microsoft.com/en-us/powershell/microsoftgraph/find-mg-graph-permission?view=graph-powershell-1.0
Find-MgGraphPermission

Find-MgGraphPermission Calendar
Find-MgGraphPermission Calendar -PermissionType 'Delegated'
Find-MgGraphPermission Calendar -PermissionType 'Application'
Find-MgGraphCommand -Command Get-MgUserCalendar | Select-Object -ExpandProperty Permissions | Select-Object Name, PermissionType, IsAdmin, Description, FullDescription | Sort-Object PermissionType | Format-Table
#endregion

#region Permissions and Scopes
# You can check the granted permissions using the Get-MgUserOAuth2PermissionGrant command.
Connect-MgGraph -Scopes "User.Read.All"
Get-MgContext | Select-Object -ExpandProperty Scopes
Disconnect-MgGraph
Connect-MgGraph -Scopes "Mail.ReadWrite.Shared"
Get-MgContext | Select-Object -ExpandProperty Scopes
# check all the permissions granted to the user and to which apps
Get-MgUserOauth2PermissionGrant -UserId $(Get-MgContext | Select-Object -ExpandProperty Account) | Select-Object -ExpandProperty Scope | Select-Object -Unique


Find-MgGraphPermission user -PermissionType "Delegated" | Where-Object Consent -EQ "User"

# All Application permisions requires an admin consent due to the scope of the permission.
Find-MgGraphPermission user -PermissionType "Application"
#endregion
