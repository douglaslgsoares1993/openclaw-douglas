$ErrorActionPreference = "Continue"

# Sobe Open WebUI somente apos confirmacao.

$ComposeFile = Join-Path $PSScriptRoot "docker-compose.open-webui.yml"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker nao encontrado."
    exit 1
}

try {
    docker version | Out-Host
} catch {
    Write-Host "Docker nao respondeu: $($_.Exception.Message)"
    exit 1
}

try {
    Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 10 | Out-Null
    Write-Host "Ollama local OK."
} catch {
    Write-Host "Ollama local nao respondeu em http://localhost:11434/api/tags"
    exit 1
}

$answer = Read-Host "Deseja subir Open WebUI em http://localhost:3000? (s/N)"
if ($answer -notmatch '^(s|sim|y|yes)$') {
    Write-Host "Operacao cancelada."
    exit 0
}

docker compose -f $ComposeFile up -d
Write-Host "Open WebUI solicitado em: http://localhost:3000"
Write-Host "Acesso LAN futuro exige politica, firewall/rede e autenticacao apropriados."
