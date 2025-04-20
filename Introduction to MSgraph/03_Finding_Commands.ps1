#region Find commands:
# Reference Docs: https://learn.microsoft.com/en-us/powershell/microsoftgraph/find-mg-graph-command?view=graph-powershell-1.0
Find-MgGraphCommand -Uri '/users/{id}'

Find-MgGraphCommand -Command 'Get-MgUser'

# .* is a wildcard for any character 0 or more times
# .*User.* is a regex pattern that matches any command containing 'User'
Find-MgGraphCommand -Command .*User.*
Find-MgGraphCommand -Command .*User.*.*memberOf.*
Find-MgGraphCommand -Command .*User.*.*memberOf.*.*Unit.*

Find-MgGraphCommand -Uri ".*users.*" -Method 'Get' -ApiVersion 'v1.0'
Find-MgGraphCommand -Uri ".*users.*.*memberOf.*" -Method 'Get' -ApiVersion 'v1.0'
Find-MgGraphCommand -Uri ".*users.*.*memberOf.*.*Unit.*" -Method 'Get' -ApiVersion 'v1.0'

#endregion
