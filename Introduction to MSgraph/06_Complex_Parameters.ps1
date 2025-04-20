#region Complex body parameters
# Reference Docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users.actions/send-mgusermail?view=graph-powershell-1.0
Import-Module Microsoft.Graph.Users.Actions


$params = @{
    message         = @{
        subject      = "Test HTML email from PowerShell"
        body         = @{
            contentType = "HTML"
            content     = @"
                # This is a test email sent from PowerShell using Microsoft Graph.
                <html><body>
                <h1>Hello World</h1>
                <p>This is a test email sent from PowerShell using Microsoft Graph.</p>

                <img src='https://mynster9361.github.io/assets/img/posts/me.png' alt='me' style='width: 200px; height: auto;' />
                <p>Best regards,</p>
                </body></html>
"@
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = $env:tstUserId # tstUserToSendTo
                }
            }
        )
    }
    saveToSentItems = "true"
}

# A UPN can also be used as -UserId.
Send-MgUserMail -UserId $env:tstUserId -BodyParameter $params # tstUserToSendTo
#endregion

#region using the -debug switch

Send-MgUserMail -UserId $env:tstUserId -BodyParameter $params -Debug
# The -Debug switch will show you the raw HTTP request and response, including the URL, headers, and body.
# This is useful for troubleshooting and understanding how the API works.
