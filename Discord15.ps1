
# عنوان الويب هوك الخاص بك
$webhook_url = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7"


$embed = @{
    title = "🚀 PowerShell Notification"
    description = "A message has been sent with a [clickable link](https://discord.com)!"
    color = 5814783
    fields = @(
        @{
            name = "📦 Tokens Found"
            value = "```QQ```"
            inline = $false
        },
        @{
            name = "🔗 Link Example"
            value = "[Open Discord](https://discord.com)"
            inline = $true
        }
    )
    footer = @{
        text = "Sent via PowerShell • " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
    thumbnail = @{
        url = "https://i.imgur.com/Z4mB6rL.png"
    }
}

$payload = @{
    username = "🔔 Notification Bot"
    avatar_url = "https://i.imgur.com/Z4mB6rL.png"
    embeds = @($embed)
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType 'application/json'
