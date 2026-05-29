$ErrorActionPreference = "Continue"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDir = Join-Path $RepoRoot "logs\dev-setup"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportPath = Join-Path $LogDir "RELATORIO_AMBIENTE_DEV_$Stamp.md"

# Este script e somente leitura: coleta versoes e escreve um relatorio local.
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Add-Line {
    param([string]$Text = "")
    $Text | Out-File -FilePath $ReportPath -Append -Encoding UTF8
}

function Get-ToolResult {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Command,
        [string[]]$Arguments = @()
    )

    # Get-Command evita executar instaladores ou alterar configuracoes.
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return [pscustomobject]@{
            Name = $Name
            Found = $false
            Version = "Nao encontrado"
            Path = ""
        }
    }

    try {
        $output = & $Command @Arguments 2>&1 | Out-String
        $version = if ([string]::IsNullOrWhiteSpace($output)) { "Encontrado" } else { $output.Trim() }
        return [pscustomobject]@{
            Name = $Name
            Found = $true
            Version = $version
            Path = $cmd.Source
        }
    } catch {
        return [pscustomobject]@{
            Name = $Name
            Found = $true
            Version = "Erro: $($_.Exception.Message)"
            Path = $cmd.Source
        }
    }
}

Add-Line "# Relatorio de ambiente de desenvolvimento"
Add-Line ""
Add-Line ("Gerado em: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"))
Add-Line ("Repositorio: " + $RepoRoot)
Add-Line ""

Add-Line "## Sistema"
Add-Line ""
try {
    $os = Get-CimInstance Win32_OperatingSystem
    Add-Line ("- Windows: {0} {1}, build {2}, {3}" -f $os.Caption, $os.Version, $os.BuildNumber, $os.OSArchitecture)
} catch {
    Add-Line ("- Windows: erro ao consultar - " + $_.Exception.Message)
}
Add-Line ("- PowerShell: " + $PSVersionTable.PSVersion.ToString())
Add-Line ""

# Lista de ferramentas esperadas para desenvolvimento IA_DELEGACIA/OpenClaw.
$tools = @(
    @{Name="Git"; Command="git"; Args=@("--version")},
    @{Name="GitHub CLI"; Command="gh"; Args=@("--version")},
    @{Name="Node.js"; Command="node"; Args=@("--version")},
    @{Name="npm"; Command="npm"; Args=@("--version")},
    @{Name="pnpm"; Command="pnpm"; Args=@("--version")},
    @{Name="Python"; Command="python"; Args=@("--version")},
    @{Name="py launcher"; Command="py"; Args=@("--version")},
    @{Name="uv"; Command="uv"; Args=@("--version")},
    @{Name="Docker"; Command="docker"; Args=@("--version")},
    @{Name="VS Code"; Command="code"; Args=@("--version")},
    @{Name="Ollama"; Command="ollama"; Args=@("--version")},
    @{Name="cloudflared"; Command="cloudflared"; Args=@("--version")},
    @{Name="ffmpeg"; Command="ffmpeg"; Args=@("-version")},
    @{Name="jq"; Command="jq"; Args=@("--version")},
    @{Name="ripgrep"; Command="rg"; Args=@("--version")},
    @{Name="fd"; Command="fd"; Args=@("--version")},
    @{Name="nvidia-smi"; Command="nvidia-smi"; Args=@()}
)

$results = foreach ($tool in $tools) {
    Get-ToolResult -Name $tool.Name -Command $tool.Command -Arguments $tool.Args
}

Add-Line "## Ferramentas"
Add-Line ""
Add-Line "| Ferramenta | Status | Versao/Saida | Caminho |"
Add-Line "| --- | --- | --- | --- |"
foreach ($result in $results) {
    $status = if ($result.Found) { "OK" } else { "Pendente" }
    $version = ($result.Version -replace "\r?\n", "<br>")
    $path = $result.Path
    Add-Line ("| {0} | {1} | {2} | {3} |" -f $result.Name, $status, $version, $path)
}
Add-Line ""

Add-Line "## Modelos Ollama"
Add-Line ""
$ollama = Get-Command "ollama" -ErrorAction SilentlyContinue
if ($ollama) {
    try {
        # ollama list apenas consulta modelos ja presentes.
        Add-Line '```text'
        (& ollama list 2>&1 | Out-String).Trim() | ForEach-Object { Add-Line $_ }
        Add-Line '```'
    } catch {
        Add-Line ("Erro ao executar ollama list: " + $_.Exception.Message)
    }
} else {
    Add-Line "Comando ollama nao encontrado nesta sessao."
}
Add-Line ""

Add-Line "## Espaco em disco"
Add-Line ""
Add-Line "| Unidade | Total GB | Livre GB |"
Add-Line "| --- | ---: | ---: |"
foreach ($driveLetter in @("C:", "D:")) {
    # Consulta de disco via WMI, sem alterar unidades.
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$driveLetter'" -ErrorAction SilentlyContinue
    if ($disk) {
        Add-Line ("| {0} | {1} | {2} |" -f $driveLetter, [math]::Round($disk.Size / 1GB, 2), [math]::Round($disk.FreeSpace / 1GB, 2))
    } else {
        Add-Line ("| {0} | N/A | N/A |" -f $driveLetter)
    }
}
Add-Line ""

Add-Line "## Observacoes"
Add-Line ""
Add-Line "- Este script e somente diagnostico."
Add-Line "- Nao instala programas."
Add-Line "- Nao altera tokens, Render, Ollama, modelos, rede, firewall ou servicos."

Write-Host "Relatorio gerado em: $ReportPath"
