$ErrorActionPreference = "Continue"

$ComposeFile = Join-Path $PSScriptRoot "docker-compose.open-webui.yml"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker nao encontrado."
    exit 1
}

docker compose -f $ComposeFile down
Write-Host "Open WebUI parado."
