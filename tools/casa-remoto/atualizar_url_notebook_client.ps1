param(
    [Parameter(Mandatory=$true)][string]$BaseUrl
)

$ErrorActionPreference = "Stop"

# Atualiza exemplos de BASE_URL nos clientes, sempre com backup.

if ($BaseUrl -notmatch '^https://') {
    Write-Host "URL rejeitada. Informe uma URL iniciada por https://"
    exit 1
}

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $RepoRoot "backups\casa-remoto\$Stamp"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

$targets = @(
    "tools\notebook-client\teste_ia_delegacia.ps1",
    "tools\notebook-client\chat_ia_delegacia.ps1"
)

$directDir = Join-Path $RepoRoot "tools\direct-ollama-access"
if (Test-Path -LiteralPath $directDir) {
    Get-ChildItem -LiteralPath $directDir -File -Include "*.ps1","*.md" -ErrorAction SilentlyContinue |
        ForEach-Object { $targets += (Resolve-Path -LiteralPath $_.FullName).Path.Substring($RepoRoot.Path.Length + 1) }
}

$patterns = @(
    'https://don-pike-suggestions-reveals\.trycloudflare\.com',
    'https://[A-Za-z0-9-]+\.trycloudflare\.com'
)

foreach ($relative in $targets | Sort-Object -Unique) {
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) { continue }

    $backupPath = Join-Path $BackupDir ($relative -replace '[\\/:*?"<>|]', '_')
    Copy-Item -LiteralPath $path -Destination $backupPath -Force

    $content = Get-Content -LiteralPath $path -Raw
    foreach ($pattern in $patterns) {
        $content = [Regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $BaseUrl })
    }
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    Write-Host "Atualizado: $path"
}

Write-Host "Backups em: $BackupDir"
