$ErrorActionPreference = "Continue"

# Assistente para recriar o Cloudflare quick tunnel sem matar processos automaticamente.

$CloudflaredPath = "C:\IA_DELEGACIA\99_MANUTENCAO\cloudflared.exe"
$Command = "$CloudflaredPath tunnel --url http://localhost:11434 --http-host-header localhost:11434"

Write-Host "Recuperacao de quick tunnel - IA_DELEGACIA"
Write-Host ""
Write-Host "1. Verifique se ja existe uma janela cloudflared antiga aberta."
Write-Host "2. Se quiser encerrar a antiga, faca manualmente apos confirmar que nao ha uso ativo."
Write-Host "3. Este script NAO mata processos automaticamente."
Write-Host ""
Write-Host "Comando recomendado:"
Write-Host $Command
Write-Host ""

if (-not (Test-Path -LiteralPath $CloudflaredPath)) {
    Write-Host "ATENCAO: cloudflared.exe nao encontrado em $CloudflaredPath"
    Write-Host "Ajuste o caminho antes de rodar o comando."
} else {
    $run = Read-Host "Deseja abrir uma nova janela com o quick tunnel agora? (s/N)"
    if ($run -match '^(s|sim|y|yes)$') {
        Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", "`"$Command`""
        Write-Host "Nova janela solicitada. Copie a URL https://...trycloudflare.com exibida pelo cloudflared."
    }
}

$url = Read-Host "Informe a nova URL para testar, ou deixe vazio para sair"
if ([string]::IsNullOrWhiteSpace($url)) {
    Write-Host "Nenhuma URL informada. Encerrando."
    exit 0
}

if ($url -notmatch '^https://') {
    Write-Host "URL rejeitada: informe uma URL iniciada por https://"
    exit 1
}

$url = $url.TrimEnd("/")
$model = "qwen2.5:14b"

Write-Host "Testando $url/api/tags"
try {
    Invoke-RestMethod -Uri "$url/api/tags" -Method Get -TimeoutSec 30 | Out-Host
    Write-Host "/api/tags OK"
} catch {
    Write-Host "/api/tags FALHOU: $($_.Exception.Message)"
}

Write-Host "Testando /api/generate com $model"
$body = @{
    model = $model
    prompt = "Responda em portugues, em uma frase curta: tunnel recuperado."
    stream = $false
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "$url/api/generate" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 120
    Write-Host "Geracao OK:"
    Write-Host $response.response
} catch {
    Write-Host "/api/generate FALHOU: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Sugestao: atualize os scripts do notebook com:"
Write-Host "powershell.exe -ExecutionPolicy Bypass -File .\tools\casa-remoto\atualizar_url_notebook_client.ps1 -BaseUrl `"$url`""
