<# Articles coverting this
https://mynster9361.github.io/posts/ActionableMessages/
https://mynster9361.github.io/posts/ActionableMessagesPart2/
#>

# Originator id
$originatorId = $env:originatorId

# Your url for the logic app saved from earlier the same one used for the `HTTP URL` for mine it looks something like this
$httpURL = $env:httpURL

# Tenant ID, Client ID, and Client Secret for the MS Graph API
$tenantId = $env:tenantId
$clientId = $env:clientId
$clientSecret = $env:clientSecret
$userToSendFrom = $env:userToSendFrom
$userToSendTo = $env:userToSendTo

# Example values for other variables
$userName = "John Doe"
$userUPN = "John.Doe@contoso.com"
$header = "We need a new owner to replace $userName"
$userImage = "https://pbs.twimg.com/profile_images/3647943215/d7f12830b3c17a5a9e4afcc370e3a37e_400x400.jpeg"
$reason = "We can see the employee is set to leave the company on $date and request that you as the manager choose a new person to be responsible for the things the previous employee was set as owner of."
$date = Get-Date -Format "yyyy-MM-dd, HH:mm"


$dirrectReports = @(
    @{
        title = "Bob Bob"
        value = "Bob.Bob@contoso.com"
    },
    @{
        title = "Jane Doe"
        value = "Jane.Doe@contoso.com"
    },
    @{
        title = "John Doe"
        value = "John.Doe@contoso.com"
    },
    @{
        title = "Shane Doe"
        value = "Shane.Doe@contoso.com"
    }
)

$ownedObjects = @(
    @{
        title = "Group_Name"
        value = "Group"
    },
    @{
        title = "service_user"
        value = "User"
    },
    @{
        title = "Server_Name"
        value = "Server"
    },
    @{
        title = "Server_Name1"
        value = "Server"
    },
    @{
        title = "Server_Name2"
        value = "Server"
    },
    @{
        title = "Server_Name3"
        value = "Server"
    }
)

# Transform the factSet to create a new array with Type and Name properties
$transformedFactSet = $ownedObjects | ForEach-Object {
    [PSCustomObject]@{
        Type = $_.value
        Name = $_.title
    }
}

# Convert the transformed array to a JSON string needs to be oneline which is why we use -Compress
$objectsJoined = $transformedFactSet | ConvertTo-Json -Compress

# Manually escape the quotes in the JSON string needed for adaptive cards
$objectsJoinedEscaped = $objectsJoined -replace '"', '\"'


$params = @{
    message         = @{
        subject      = "$header"
        body         = @{
            contentType = "HTML"
            content     = @"
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <script type="application/adaptivecard+json">
{
    "type": "AdaptiveCard",
    "version": "1.2",
    "originator": "$($originatorId)",
    "hideOriginalBody": true,
    "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "body": [
        {
            "type": "Container",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "$header",
                    "wrap": true
                }
            ]
        },
        {
            "type": "Container",
            "items": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "Image",
                                    "style": "Person",
                                    "url": "$userImage",
                                    "altText": "$userName",
                                    "size": "Small"
                                }
                            ],
                            "width": "auto"
                        },
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "weight": "Bolder",
                                    "text": "$userName",
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Requested on the: $date",
                                    "isSubtle": true,
                                    "wrap": true
                                },
                                {
                                    "type": "TextBlock",
                                    "spacing": "None",
                                    "text": "Reason: $reason",
                                    "isSubtle": true,
                                    "wrap": true
                                }
                            ],
                            "width": "stretch"
                        }
                    ]
                }
            ]
        },
        {
            "type": "FactSet",
            "facts": $($ownedObjects | ConvertTo-Json),
            "id": "facts"
        },
        {
            "type": "Input.ChoiceSet",
            "choices": $($dirrectReports | ConvertTo-Json),
            "placeholder": "Please choose one of your direct reports as the new owner",
            "id": "choice"
        },
        {
            "type": "ActionSet",
            "actions": [
                {
                    "type": "Action.Http",
                    "title": "Sellect new owner",
                    "id": "approve",
                    "iconUrl": "",
                    "method": "POST",
                    "body": "{\"Action\":\"Approve\",\"New_Owner\":\"{{choice.value}}\",\"Old_Owner\":\"$($userUPN)\",\"Objects\":$($objectsJoinedEscaped)}",
                    "url": "$($httpURL)",
                    "headers": [
                        {
                            "name": "Authorization",
                            "value": ""
                        },
                        {
                            "name": "Content-type",
                            "value": "text/plain"
                        }
                    ]
                }
            ]
        }
    ]
}
        </script>
        </head>
        <p>Please find a new owner for the group and fill it in below and press submit. Thank you ín advance! </p>
        </html>
"@
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "$userToSendTo"
                }
            }
        )

    }
    saveToSentItems = "false"
} | ConvertTo-Json -Depth 10

# Default Token Body
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
# Request a Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $tokenBody

# Setting up the authorization headers
$authHeaders = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

# Graph API BASE URI
$graphApiUri = "https://graph.microsoft.com/v1.0"
$uri = "$graphApiUri/users/$userToSendFrom/sendMail"
$request = Invoke-RestMethod -Method POST -Uri $uri -Headers $authHeaders -Body $params
$request
<#
 The script is a bit long, but it is quite simple. It sends an email to a user with an adaptive card that has a choice set and a fact set. The user can then choose a new owner for a group and submit the choice.
 The script uses the  ConvertTo-Json  cmdlet to convert the  $factSet  and  $choiceSet  arrays to JSON strings. It then manually escapes the quotes in the JSON string needed for adaptive cards.
 The script then creates a  $params  object with the email message, subject, body, and recipient. It then converts the object to a JSON string.
 The script then requests a token from the Microsoft Graph API using the  Invoke-RestMethod  cmdlet. It then sets up the authorization headers and sends the email using the  Invoke-RestMethod  cmdlet.
 Conclusion
 In this article, you learned how to send an email with an adaptive card using PowerShell. You learned how to create an adaptive card with a choice set and a fact set.
 You also learned how to send the email using the Microsoft Graph API.
 I hope this article helps you send emails with adaptive cards using PowerShell.
 If you have any questions or feedback, please leave a comment.
 #>
