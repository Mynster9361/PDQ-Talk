#region Introduction
# Install the modules
# New version dropped 20-Apr 2.27.0
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module Microsoft.Graph.Beta -Scope CurrentUser

# Import the module you need instead of the entire module for increased performance.
Import-Module Microsoft.Graph
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Measure-Command {
    Import-Module Microsoft.Graph
}
<#
Days              : 0
Hours             : 0
Minutes           : 4
Seconds           : 50
Milliseconds      : 607
Ticks             : 2906076527
TotalDays         : 0,00336351449884259
TotalHours        : 0,0807243479722222
TotalMinutes      : 4,84346087833333
TotalSeconds      : 290,6076527
TotalMilliseconds : 290607,6527
#>

Measure-Command {
    Import-Module Microsoft.Graph.Authentication
}
<#
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 14
Ticks             : 143730
TotalDays         : 1,66354166666667E-07
TotalHours        : 3,9925E-06
TotalMinutes      : 0,00023955
TotalSeconds      : 0,014373
TotalMilliseconds : 14,373
#>

# To see all available commands
Get-Command -Module Microsoft.Graph.* | Measure-Object

#endregion
