param(
    [string]$BaseUrl = $env:IA_DELEGACIA_BASE_URL,
    [string]$Model = $env:IA_DELEGACIA_MODEL,
    [int]$TimeoutSec = 180
)

$ErrorActionPreference = "Continue"

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = Read-Host "BASE_URL do Ollama"
}
if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = "qwen2.5:14b"
}
$BaseUrl = $BaseUrl.TrimEnd("/")

function Get-Tags {
    try {
        Invoke-RestMethod -Uri "$BaseUrl/api/tags" -Method Get -TimeoutSec 20
    } catch {
        Write-Host "Status indisponivel: $($_.Exception.Message)"
    }
}

Write-Host "Chat IA_DELEGACIA"
Write-Host "Base: $BaseUrl"
Write-Host "Modelo: $Model"
Write-Host "Comandos: sair | status | modelo"

while ($true) {
    $inputText = Read-Host "voce"
    if ([string]::IsNullOrWhiteSpace($inputText)) { continue }
    if ($inputText -eq "sair") { break }
    if ($inputText -eq "status") {
        $tags = Get-Tags
        if ($tags.models) {
            $tags.models | Select-Object name, size, modified_at | Format-Table -AutoSize
        }
        continue
    }
    if ($inputText -eq "modelo") {
        $newModel = Read-Host "Novo modelo"
        if (-not [string]::IsNullOrWhiteSpace($newModel)) {
            $Model = $newModel
            Write-Host "Modelo alterado para $Model"
        }
        continue
    }

    $body = @{
        model = $Model
        prompt = $inputText
        stream = $false
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/generate" -Method Post -ContentType "application/json" -Body $body -TimeoutSec $TimeoutSec
        Write-Host "ia:"
        Write-Host $response.response
    } catch {
        Write-Host "Erro ao consultar IA: $($_.Exception.Message)"
    }
}

Write-Host "Chat encerrado."
