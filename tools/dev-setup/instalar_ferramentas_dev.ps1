$ErrorActionPreference = "Continue"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDir = Join-Path $RepoRoot "logs\dev-setup"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogPath = Join-Path $LogDir "INSTALACAO_ASSISTIDA_DEV_$Stamp.log"

# Este script e assistido: cada grupo exige confirmacao explicita.
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Write-Log {
    param([string]$Text = "")
    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Text
    $line | Tee-Object -FilePath $LogPath -Append
}

function Confirm-Step {
    param([string]$Question)
    # Padrao seguro: qualquer resposta diferente de sim pula o grupo.
    $answer = Read-Host "$Question (s/N)"
    return ($answer -match '^(s|sim|y|yes)$')
}

function Invoke-Logged {
    param([string]$CommandLine)
    # Registra o comando executado e sua saida, sem lidar com tokens.
    Write-Log "Executando: $CommandLine"
    try {
        $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $CommandLine 2>&1 | Out-String
        if (-not [string]::IsNullOrWhiteSpace($output)) {
            $output.TrimEnd() | Tee-Object -FilePath $LogPath -Append
        }
    } catch {
        Write-Log ("Erro: " + $_.Exception.Message)
    }
}

function Require-Winget {
    # winget e preferido para ferramentas Windows; se ausente, nada e instalado.
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log "winget nao encontrado. Pulei este grupo."
        return $false
    }
    return $true
}

Write-Log "Inicio da instalacao assistida do ambiente dev"
Write-Log "Este script nao mexe em tokens, Render, Ollama, modelos, rede, firewall ou servicos."

if (Confirm-Step "Instalar ferramentas basicas: PowerShell 7, Windows Terminal, VS Code, 7-Zip?") {
    # Grupo de utilitarios de uso geral.
    if (Require-Winget) {
        Invoke-Logged "winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id Microsoft.WindowsTerminal --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id Microsoft.VisualStudioCode --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id 7zip.7zip --source winget --accept-package-agreements --accept-source-agreements"
    }
} else {
    Write-Log "Grupo ferramentas basicas ignorado pelo usuario."
}

if (Confirm-Step "Instalar ferramentas dev: Python 3.12, uv, Docker Desktop?") {
    # Grupo de runtime/desenvolvimento local.
    if (Require-Winget) {
        Invoke-Logged "winget install --id Python.Python.3.12 --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id Astral-sh.uv --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id Docker.DockerDesktop --source winget --accept-package-agreements --accept-source-agreements"
    }
} else {
    Write-Log "Grupo dev ignorado pelo usuario."
}

if (Confirm-Step "Instalar ferramentas de terminal: ripgrep, fd, jq, FFmpeg?") {
    # Grupo de ferramentas CLI para busca, JSON e midia.
    if (Require-Winget) {
        Invoke-Logged "winget install --id BurntSushi.ripgrep.MSVC --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id sharkdp.fd --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id jqlang.jq --source winget --accept-package-agreements --accept-source-agreements"
        Invoke-Logged "winget install --id Gyan.FFmpeg --source winget --accept-package-agreements --accept-source-agreements"
    }
} else {
    Write-Log "Grupo terminal ignorado pelo usuario."
}

if (Confirm-Step "Instalar ferramentas Node globais: pnpm, yarn?") {
    # npm global e usado somente para gerenciadores Node.
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Invoke-Logged "npm install -g pnpm yarn"
    } else {
        Write-Log "npm nao encontrado. Pulei pnpm/yarn."
    }
} else {
    Write-Log "Grupo node ignorado pelo usuario."
}

Write-Log "Fim da instalacao assistida. Log: $LogPath"
Write-Host "Log gerado em: $LogPath"
