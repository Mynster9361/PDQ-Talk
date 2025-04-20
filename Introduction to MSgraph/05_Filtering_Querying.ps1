#region Filtering Basics
Get-MgUser -Filter "country eq 'Denmark'"

# Design you filters to be as specific as possible to reduce the amount of data returned. For example, if you are looking for users in a specific department and city, you can combine filters using the AND operator.
# This will return all users in the IT department and located in Cities starting with BR. Note that this is not case sensitive.
Get-MgUser -Filter "accountEnabled eq true AND startsWith(city,'BR') AND startsWith(department,'IT')"

# Using the developer tools in the browser for easier creation of filters.
# https://portal.azure.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/AllUsers
#endregion

#region Server vs Client-side Filtering
# With the following cmdlet, we are retrieving all users and then filtering them on the client side using powerhsell.
# This is not efficient, especially if you have a large number of users in your tenant.
$(Get-MgUser -All -Property UserType | Where-Object { $_.UserType -eq 'Guest' }).count
# 23246
Measure-Command {
    Get-MgUser -All -Property UserType | Where-Object { $_.UserType -eq 'Guest' }
}
<#
Days              : 0
Hours             : 0
Minutes           : 1
Seconds           : 3
Milliseconds      : 548
Ticks             : 635486643
TotalDays         : 0,000735516947916667
TotalHours        : 0,01765240675
TotalMinutes      : 1,059144405
TotalSeconds      : 63,5486643
TotalMilliseconds : 63548,6643
#>

# The following cmdlet retrieves all guest users directly from the server using the -Filter parameter.
# This is more efficient because it reduces the amount of data transferred over the network and speeds up the query execution time.
$(Get-MgUser -All -Filter "userType eq 'Guest'").count
# 23246
Measure-Command {
    Get-MgUser -All -Filter "userType eq 'Guest'"
}
<#
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 25
Milliseconds      : 776
Ticks             : 257769796
TotalDays         : 0,000298344671296296
TotalHours        : 0,00716027211111111
TotalMinutes      : 0,429616326666667
TotalSeconds      : 25,7769796
TotalMilliseconds : 25776,9796
#>
#endregion
