# Setup Ollama - HP Z2 G9 (15ª DESEC)

## Especificações da máquina
- CPU: Intel Core i9 12ª geração
- RAM: 32GB DDR5
- GPU: NVIDIA RTX A4000 (16GB VRAM)
- OS: Windows 11 Pro
- SSD: 1TB NVMe PCIe Gen4

## Modelos recomendados
Com RTX A4000 (16GB VRAM) você roda:
- qwen2.5:32b → relatórios, resenhas, peças jurídicas (melhor para português)
- llama3.1:8b → tarefas rápidas, triagem, classificação
- mistral:7b → ultrarrápido para respostas simples
- nomic-embed-text → memória vetorial do OpenClaw

## Passo 1 - Instalar Ollama
Baixar: https://ollama.com/download/windows
Instalar normalmente. Verificar: abrir CMD → `ollama --version`

## Passo 2 - Baixar modelos
Abrir CMD como Administrador:
```cmd
ollama pull qwen2.5:32b
ollama pull llama3.1:8b
ollama pull mistral:7b
ollama pull nomic-embed-text
```
Nota: qwen2.5:32b tem ~20GB. Deixar baixando com internet boa.

## Passo 3 - Configurar Ollama para aceitar conexões externas
Criar variável de ambiente do Windows:
- Nome: OLLAMA_HOST
- Valor: 0.0.0.0:11434

Painel de Controle → Sistema → Variáveis de Ambiente → Nova (Sistema)

## Passo 4 - Instalar como serviço Windows (roda sem login)
PowerShell como Administrador:
```powershell
$ollamaPath = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
sc.exe create Ollama binPath= "$ollamaPath serve" start= auto
sc.exe start Ollama
```

## Passo 5 - Cloudflare Tunnel (expõe para o Render de forma segura)
1. Baixar cloudflared: https://github.com/cloudflare/cloudflared/releases/latest
   Arquivo: cloudflared-windows-amd64.exe
2. Renomear para cloudflared.exe e mover para C:\cloudflared\
3. Abrir CMD como Admin:
```cmd
cd C:\cloudflared
cloudflared tunnel --url http://localhost:11434
```
4. Copiar a URL gerada (ex: https://abc123.trycloudflare.com)
5. No Render → openclaw-douglas → Environment → Add:
   OLLAMA_BASE_URL = https://abc123.trycloudflare.com

## Passo 6 - Instalar cloudflared como serviço Windows
```cmd
cloudflared service install
```

## Testar integração
```cmd
curl http://localhost:11434/api/tags
```
Deve retornar JSON com modelos instalados.

## Após configurar
Avisar Douglas para adicionar OLLAMA_BASE_URL no Render.
O OpenClaw vai usar automaticamente o Ollama como provedor primário.
