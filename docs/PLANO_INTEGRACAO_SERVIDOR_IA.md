# Plano de Integração - Servidor IA (Delegacia) + OpenClaw (Notebook/Render)

## Arquitetura

```
Notebook (desenvolvimento)
    → GitHub (openclaw-douglas)
        → Render (produção 24h)
            → @openclawdouglas_bot (Telegram)
                ↓ provedor primário
    Ollama (PC Delegacia, 24h) ← Cloudflare Tunnel
                ↓ fallback
    Groq → Gemini → OpenRouter
```

## Máquinas e papéis

### PC Delegacia (pc00115-26)
- Servidor local de IA
- Roda Ollama + modelos locais
- Fica ligado 24h
- Não usado para desenvolvimento
- Modelos: qwen2.5:14b (principal), qwen3:8b (rápido), llama3.2:3b (leve), qwen3-embedding:4b (RAG)
- GPU: NVIDIA RTX 2000 Ada 16GB VRAM

### Notebook (Douglas)
- Estação de desenvolvimento e administração
- Roda OpenClaw localmente para testes
- Deploy no Render via GitHub
- WSL2 + Ubuntu 24.04

## Como funciona a integração

O OpenClaw no Render se conecta ao Ollama da delegacia via Cloudflare Tunnel:

1. PC Delegacia roda `cloudflared tunnel --url http://localhost:11434`
2. Cloudflare gera URL pública segura (ex: https://abc123.trycloudflare.com)
3. Essa URL é adicionada no Render como `OLLAMA_BASE_URL`
4. OpenClaw usa Ollama como provedor primário automaticamente
5. Se Ollama cair, cai para Groq → Gemini → OpenRouter

## Passos para ativar (quando qwen2.5:14b terminar de baixar)

1. No PC Delegacia - baixar cloudflared:
   https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe

2. No PC Delegacia - rodar o tunnel:
   ```
   cloudflared.exe tunnel --url http://localhost:11434
   ```

3. Copiar a URL gerada

4. No Render - adicionar env var:
   OLLAMA_BASE_URL = https://xxxxx.trycloudflare.com

5. Fazer redeploy no Render

6. Testar: mandar mensagem para @openclawdouglas_bot

## Segurança

- Cloudflare Tunnel não expõe IP da delegacia
- Tráfego criptografado end-to-end
- Acesso restrito via token do OpenClaw
- Dados sensíveis nunca saem da rede local
- Logs de uso registrados no PC Delegacia

## Próxima evolução (fase 2)

Quando houver necessidade de múltiplos usuários acessando o servidor local:
- Autenticação por usuário no Ollama
- Rate limiting por agente
- Logs por matrícula
- Painel de monitoramento local
