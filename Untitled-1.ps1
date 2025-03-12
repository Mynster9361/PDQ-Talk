<#
.SYNOPSIS
    Demonstrates various PowerShell code formatting settings.

.DESCRIPTION
    This script shows examples of different PowerShell code formatting settings as defined in the settings.json file.

.NOTES
    This script is for demonstration purposes only.
#>

# Example: Setting the default language mode for new files
# (This is controlled by the "files.defaultLanguage" setting in settings.json)

# Example: Trimming any final newlines at the end of files
# (This is controlled by the "files.trimFinalNewlines" setting in settings.json)

# Example: Formatting the document when saving
# (This is controlled by the "editor.formatOnSave" setting in settings.json)

# Example: Trimming trailing whitespace in PowerShell files
# (This is controlled by the "files.trimTrailingWhitespace" setting in settings.json)

# Example: Setting the code formatting options to follow the given indent style
# (This is controlled by the "powershell.codeFormatting.preset" setting in settings.json)

# Example: Adding a space between a keyword and its associated scriptblock expression
if ($true) {
    Write-Output "This is an example of whitespace before an open brace"
}

# Example: Adding a space between a keyword and its associated conditional expression
if ($true) {
    Write-Output "This is an example of whitespace before an open parenthesis"
}

# Example: Adding spaces before and after an operator
$a = 1 + 2

# Example: Adding a space after a separator
Write-Output "This is an example of whitespace after a separator", "Another example"

# Example: Automatically correcting aliases to their full cmdlet names
# (This is controlled by the "powershell.codeFormatting.autoCorrectAliases" setting in settings.json)

# Example: Trimming whitespace around the pipe character
Get-Process | Where-Object { $_.CPU -gt 100 }

# Example: Using correct casing for cmdlet names
Get-Process

# Example: Not adding a new line after a closing brace
if ($true) { Write-Output "This is an example of no new line after a closing brace" }

# Example: Aligning property value pairs
$hashTable = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning hash table keys
$hashTable = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning hash table values
$hashTable = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning pipeline elements
Get-Process |
Where-Object { $_.CPU -gt 100 } |
Select-Object -Property Name, CPU

# Example: Aligning splatted hash table keys
$splat = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning splatted hash table values
$splat = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning splatted pipeline elements
Get-Process @splat | Where-Object { $_.CPU -gt 100 } | Select-Object -Property Name, CPU

# Example: Aligning splatted parameter names
$splat = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning splatted parameter values
$splat = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Aligning splatted parameter names and values
$splat = @{
    Name  = "John"
    Age   = 30
    Email = "john@example.com"
}

# Example: Adding a new line after an opening brace
if ($true) {
    Write-Output "This is an example of a new line after an opening brace"
}

# Example: Placing the opening brace on the same line as the statement
if ($true) {
    Write-Output "This is an example of an opening brace on the same line"
}

# Example: Not adding whitespace between parameters
Write-Output "This is an example of no whitespace between parameters"

# Example: Adding whitespace inside braces
$hashTable = { Name = "John"; Age = 30; Email = "john@example.com" }

# Example: Adding whitespace around the pipe character
Get-Process | Where-Object { $_.CPU -gt 100 }