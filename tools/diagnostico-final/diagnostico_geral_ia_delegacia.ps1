param(
    [string]$PublicUrl,
    [string]$Model = "qwen2.5:14b"
)

$ErrorActionPreference = "Continue"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDir = Join-Path $RepoRoot "logs\diagnostico-final"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Report = Join-Path $LogDir "DIAGNOSTICO_GERAL_IA_DELEGACIA_$Stamp.md"

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Add-Line { param([string]$Text = "") $Text | Out-File -FilePath $Report -Append -Encoding UTF8 }

function Add-Command {
    param([string]$Title, [scriptblock]$Block)
    Add-Line "## $Title"
    Add-Line ""
    Add-Line '```text'
    try { (& $Block 2>&1 | Out-String).Trim() | ForEach-Object { Add-Line $_ } }
    catch { Add-Line $_.Exception.Message }
    Add-Line '```'
    Add-Line ""
}

function Test-Ollama {
    param([string]$Title, [string]$BaseUrl)
    Add-Line "## $Title"
    Add-Line ""
    if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        Add-Line "PENDENTE: URL nao informada."
        Add-Line ""
        return
    }
    $BaseUrl = $BaseUrl.TrimEnd("/")
    Add-Line "- URL: $BaseUrl"
    try {
        Invoke-RestMethod -Uri "$BaseUrl/api/tags" -Method Get -TimeoutSec 20 | ConvertTo-Json -Depth 5 | ForEach-Object { Add-Line $_ }
    } catch {
        Add-Line "- /api/tags falhou: $($_.Exception.Message)"
    }
    $body = @{ model = $Model; prompt = "Responda em portugues: diagnostico IA_DELEGACIA."; stream = $false } | ConvertTo-Json -Depth 5
    try {
        $r = Invoke-RestMethod -Uri "$BaseUrl/api/generate" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 120
        Add-Line "- Geracao OK: $($r.response)"
    } catch {
        Add-Line "- /api/generate falhou: $($_.Exception.Message)"
    }
    Add-Line ""
}

Add-Line "# Diagnostico geral IA_DELEGACIA"
Add-Line ""
Add-Line ("Gerado em: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"))
Add-Line ""

Add-Command "Git status" { git status --short }
Add-Command "Ultimos commits" { git log --oneline -5 }
Test-Ollama -Title "Ollama local" -BaseUrl "http://localhost:11434"
Test-Ollama -Title "URL publica" -BaseUrl $PublicUrl
Add-Command "GPU nvidia-smi" { nvidia-smi }
Add-Command "Discos C e D" { Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID,VolumeName,@{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}},@{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize }

Add-Line "## Arquivos principais"
Add-Line ""
$files = @(
    "tools\notebook-client\teste_ia_delegacia.ps1",
    "tools\notebook-client\chat_ia_delegacia.ps1",
    "tools\casa-remoto\recuperar_tunnel_quick.ps1",
    "tools\open-webui-local\docker-compose.open-webui.yml",
    "tools\final-expediente\checklist_final_expediente.ps1"
)
foreach ($f in $files) {
    $p = Join-Path $RepoRoot $f
    Add-Line ("- {0}: {1}" -f $f, (Test-Path -LiteralPath $p))
}
Add-Line ""

Add-Line "## Ferramentas locais"
Add-Line ""
Add-Line ("- Chrome Remote Desktop parece instalado: " + [bool](Get-ChildItem "C:\Program Files","C:\Program Files (x86)" -Recurse -ErrorAction SilentlyContinue -Filter "remoting_host.exe" | Select-Object -First 1))
Add-Line ("- cloudflared.exe existe: " + (Test-Path -LiteralPath "C:\IA_DELEGACIA\99_MANUTENCAO\cloudflared.exe"))
Add-Line ("- WSL existe: " + [bool](Get-Command wsl.exe -ErrorAction SilentlyContinue))

Write-Host "Relatorio gerado em: $Report"
