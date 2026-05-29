$ErrorActionPreference = "Continue"

$ComposeFile = Join-Path $PSScriptRoot "docker-compose.open-webui.yml"

Write-Host "Docker:"
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker --version
    docker compose -f $ComposeFile ps
} else {
    Write-Host "Docker nao encontrado."
}

Write-Host ""
Write-Host "Porta 3000:"
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess | Format-Table -AutoSize

Write-Host ""
Write-Host "Ollama local:"
try {
    Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 10 | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Ollama nao respondeu: $($_.Exception.Message)"
}
