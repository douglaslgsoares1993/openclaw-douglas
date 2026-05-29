$ErrorActionPreference = "Continue"

Write-Host "Diagnostico seguro do Telegram Bot API"
Write-Host "O token nao sera salvo nem impresso integralmente."
Write-Host ""

$token = Read-Host "Cole o token do bot Telegram"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "Token vazio. Encerrando."
    exit 1
}

$prefixLength = [Math]::Min(5, $token.Length)
$prefix = $token.Substring(0, $prefixLength)
$hasColon = if ($token.Contains(":")) { "sim" } else { "nao" }

Write-Host ""
Write-Host "TELEGRAM_TOKEN_LENGTH=$($token.Length)"
Write-Host "TELEGRAM_TOKEN_PREFIX=$prefix"
Write-Host "TELEGRAM_TOKEN_HAS_COLON=$hasColon"
Write-Host ""

function Invoke-TelegramApi {
    param(
        [Parameter(Mandatory=$true)][string]$Method,
        [string]$Query = ""
    )

    $uri = "https://api.telegram.org/bot$token/$Method$Query"
    try {
        return Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 30
    } catch {
        Write-Host "$Method FALHOU"
        if ($_.Exception.Response) {
            Write-Host "StatusCode: $([int]$_.Exception.Response.StatusCode)"
        }
        Write-Host "Erro: $($_.Exception.Message)"
        return $null
    }
}

Write-Host "Executando getMe..."
$me = Invoke-TelegramApi -Method "getMe"
if ($me -and $me.ok) {
    Write-Host "getMe OK"
    Write-Host "Bot username: $($me.result.username)"
} elseif ($me) {
    Write-Host "getMe FALHOU"
    Write-Host "Descricao: $($me.description)"
}

Write-Host ""
Write-Host "Executando getWebhookInfo..."
$webhook = Invoke-TelegramApi -Method "getWebhookInfo"
if ($webhook -and $webhook.ok) {
    Write-Host "getWebhookInfo OK"
    Write-Host "URL: $($webhook.result.url)"
    Write-Host "Pending updates: $($webhook.result.pending_update_count)"
    if ($webhook.result.last_error_message) {
        Write-Host "Ultimo erro: $($webhook.result.last_error_message)"
    }
} elseif ($webhook) {
    Write-Host "getWebhookInfo FALHOU"
    Write-Host "Descricao: $($webhook.description)"
}

Write-Host ""
$answer = Read-Host "Deseja limpar webhook com deleteWebhook?drop_pending_updates=false? (s/N)"
if ($answer -match '^(s|sim|y|yes)$') {
    Write-Host "Limpando webhook..."
    $deleted = Invoke-TelegramApi -Method "deleteWebhook" -Query "?drop_pending_updates=false"
    if ($deleted -and $deleted.ok) {
        Write-Host "deleteWebhook OK"
        Write-Host "Descricao: $($deleted.description)"
    } elseif ($deleted) {
        Write-Host "deleteWebhook FALHOU"
        Write-Host "Descricao: $($deleted.description)"
    }
} else {
    Write-Host "Webhook nao alterado."
}

$token = $null
Write-Host "Diagnostico finalizado."
