param(
    [string]$BaseUrl = $env:IA_DELEGACIA_BASE_URL,
    [string]$Model = $env:IA_DELEGACIA_MODEL,
    [string]$Prompt = "Responda em portugues, em uma frase curta: teste da IA_DELEGACIA.",
    [int]$TimeoutSec = 90
)

$ErrorActionPreference = "Continue"

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = Read-Host "BASE_URL do Ollama (ex: https://don-pike-suggestions-reveals.trycloudflare.com ou http://localhost:11434)"
}
if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = "qwen2.5:14b"
}

$BaseUrl = $BaseUrl.TrimEnd("/")

function Show-HttpError {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)
    $response = $ErrorRecord.Exception.Response
    if ($response) {
        $code = [int]$response.StatusCode
        Write-Host "HTTP $code"
        switch ($code) {
            403 { Write-Host "403: acesso negado. Verifique Cloudflare Access, tunnel ou bloqueio intermediario." }
            404 { Write-Host "404: URL incorreta ou endpoint inexistente. Nao use /v1 para API nativa Ollama." }
            500 { Write-Host "500: erro no servidor Ollama ou no tunnel." }
        }
    } else {
        Write-Host "Erro de conexao/timeout: $($ErrorRecord.Exception.Message)"
    }
}

Write-Host "Testando tags em $BaseUrl/api/tags"
try {
    $tags = Invoke-RestMethod -Uri "$BaseUrl/api/tags" -Method Get -TimeoutSec 20
    Write-Host "Tags OK"
    if ($tags.models) {
        $tags.models | Select-Object name, size, modified_at | Format-Table -AutoSize
    }
} catch {
    Write-Host "Falha em /api/tags"
    Show-HttpError $_
    exit 1
}

Write-Host "Testando geracao com modelo $Model"
$body = @{
    model = $Model
    prompt = $Prompt
    stream = $false
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/generate" -Method Post -ContentType "application/json" -Body $body -TimeoutSec $TimeoutSec
    Write-Host "Geracao OK"
    Write-Host $response.response
} catch {
    Write-Host "Falha em /api/generate"
    Show-HttpError $_
    if ($_.Exception.Message -match "model|not found|404") {
        Write-Host "Possivel modelo inexistente: confirme com ollama list."
    }
    exit 1
}
