# Comandos modelo Windows

Estes comandos sao modelo operacional. Ajuste nomes e caminhos antes de usar.

## Login Cloudflare

```powershell
cloudflared tunnel login
```

## Criar tunnel nomeado

```powershell
cloudflared tunnel create ia-delegacia-ollama
```

## Criar rota DNS

```powershell
cloudflared tunnel route dns ia-delegacia-ollama ollama.seu-dominio.example
```

## Rodar tunnel com arquivo de configuracao

```powershell
cloudflared tunnel --config C:\IA_DELEGACIA\cloudflared\config.yml run ia-delegacia-ollama
```

## Testar localmente

```powershell
curl.exe http://localhost:11434/api/tags
```

## Testar pela URL publica

```powershell
curl.exe https://ollama.seu-dominio.example/api/tags
```

## Render

Atualizar:

```text
OLLAMA_BASE_URL=https://ollama.seu-dominio.example
OLLAMA_MODEL=qwen2.5:14b
PRIMARY_MODEL=ollama/qwen2.5:14b
FALLBACK_MODEL=groq/llama-3.3-70b-versatile
```
