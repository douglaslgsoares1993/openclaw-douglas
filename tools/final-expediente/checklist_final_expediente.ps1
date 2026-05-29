param(
    [string]$LocalBaseUrl = "http://localhost:11434",
    [string]$PublicBaseUrl = $env:IA_DELEGACIA_PUBLIC_BASE_URL,
    [string]$Model = "qwen2.5:14b",
    [int]$TimeoutSec = 120
)

$ErrorActionPreference = "Continue"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDir = Join-Path $RepoRoot "logs\final-expediente"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Report = Join-Path $LogDir "CHECKLIST_FINAL_EXPEDIENTE_$Stamp.md"
$Attention = $false

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

function Add-Line {
    param([string]$Text = "")
    $Text | Out-File -FilePath $Report -Append -Encoding UTF8
}

function Test-OllamaEndpoint {
    param(
        [string]$Name,
        [string]$BaseUrl
    )

    if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        Add-Line "- $($Name): PENDENTE - URL nao informada"
        $script:Attention = $true
        return
    }

    $BaseUrl = $BaseUrl.TrimEnd("/")
    Add-Line "### $Name"
    Add-Line ""
    try {
        Invoke-RestMethod -Uri "$BaseUrl/api/tags" -Method Get -TimeoutSec 20 | Out-Null
        Add-Line "- /api/tags: OK"
    } catch {
        Add-Line "- /api/tags: FALHOU - $($_.Exception.Message)"
        $script:Attention = $true
        return
    }

    $body = @{
        model = $Model
        prompt = "Responda em portugues, em uma frase curta: checklist final do expediente."
        stream = $false
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/generate" -Method Post -ContentType "application/json" -Body $body -TimeoutSec $TimeoutSec
        Add-Line "- Geracao com $($Model): OK"
        Add-Line "- Resposta: $($response.response)"
    } catch {
        Add-Line "- Geracao com $($Model): FALHOU - $($_.Exception.Message)"
        $script:Attention = $true
    }
    Add-Line ""
}

Add-Line "# Checklist final do expediente"
Add-Line ""
Add-Line ("Gerado em: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"))
Add-Line ""

Test-OllamaEndpoint -Name "Ollama local" -BaseUrl $LocalBaseUrl
Test-OllamaEndpoint -Name "URL publica" -BaseUrl $PublicBaseUrl

Add-Line "## GPU"
Add-Line ""
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    Add-Line '```text'
    (& nvidia-smi 2>&1 | Out-String).Trim() | ForEach-Object { Add-Line $_ }
    Add-Line '```'
} else {
    Add-Line "- nvidia-smi nao encontrado"
    $Attention = $true
}
Add-Line ""

Add-Line "## Discos"
Add-Line ""
Add-Line "| Unidade | Total GB | Livre GB |"
Add-Line "| --- | ---: | ---: |"
foreach ($driveLetter in @("C:", "D:")) {
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$driveLetter'" -ErrorAction SilentlyContinue
    if ($disk) {
        Add-Line ("| {0} | {1} | {2} |" -f $driveLetter, [math]::Round($disk.Size / 1GB, 2), [math]::Round($disk.FreeSpace / 1GB, 2))
    } else {
        Add-Line ("| {0} | N/A | N/A |" -f $driveLetter)
        $Attention = $true
    }
}
Add-Line ""

if ($Attention) {
    Add-Line "## Resultado"
    Add-Line ""
    Add-Line "ATENCAO: ha pendencias antes de sair."
    Write-Host "ATENCAO"
} else {
    Add-Line "## Resultado"
    Add-Line ""
    Add-Line "PODE SAIR COM SEGURANCA"
    Write-Host "PODE SAIR COM SEGURANCA"
}

Write-Host "Relatorio gerado em: $Report"
