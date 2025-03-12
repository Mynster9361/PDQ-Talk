param (
    [string]$Action,
    [string]$New_Owner,
    [string]$Old_Owner,
    [PSCustomObject[]]$Objects
)

Write-Output "Hello Logic app, these are the variables I received:"
Write-Output "Action: $Action"
Write-Output "New_Owner: $New_Owner"
Write-Output "Old_Owner: $Old_Owner"

Write-Output "Making foreach loop with a switch on type for all Objects:"

# Example of accessing individual properties
foreach ($obj in $Objects) {
    switch ($obj.Type) {
        "Group" {
            Write-Output "$($obj.Name) is a group"
        }
        "User" {
            Write-Output "$($obj.Name) is a user"
        }
        "Server" {
            Write-Output "$($obj.Name) is a server"
        }
        default {
            Write-Output "$($obj.Name) is an unknown type"
        }
    }
}