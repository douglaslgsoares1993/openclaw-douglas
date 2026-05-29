# Ollama no Render

Este projeto usa o Ollama local da Delegacia como provedor preferencial quando `OLLAMA_BASE_URL` esta configurada no Render. O bot continua preservando Telegram e os provedores externos como fallback.

## Variaveis de ambiente no Render

Configurar no servico `openclaw-douglas`:

```text
OLLAMA_BASE_URL=https://friendship-anticipated-monitors-lows.trycloudflare.com
OLLAMA_MODEL=qwen2.5:14b
PRIMARY_MODEL=ollama/qwen2.5:14b
FALLBACK_MODEL=groq/llama-3.3-70b-versatile
```

Observacoes:

- `OLLAMA_BASE_URL` deve apontar para a URL base do tunnel, sem `/v1` e sem caminho adicional.
- `OLLAMA_MODEL` tem padrao `qwen2.5:14b`.
- `PRIMARY_MODEL` tem padrao `ollama/qwen2.5:14b` quando `OLLAMA_BASE_URL` existe.
- `FALLBACK_MODEL` tem padrao `groq/llama-3.3-70b-versatile`.
- Nao inserir tokens reais no repositorio.

## Cloudflare Tunnel temporario

No PC da Delegacia, com Ollama rodando localmente:

```powershell
cloudflared tunnel --url http://localhost:11434
```

Copiar a URL `https://...trycloudflare.com` gerada e atualizar `OLLAMA_BASE_URL` no Render.

Importante: URLs `trycloudflare.com` sao temporarias. Se o tunnel cair ou for reiniciado, a URL muda e o Render precisa ser atualizado com a nova URL.

## Como funciona no container

Quando `OLLAMA_BASE_URL` existe:

1. O entrypoint seleciona `PRIMARY_MODEL=ollama/qwen2.5:14b`, salvo se a variavel for sobrescrita.
2. O container sobe um proxy interno em `127.0.0.1:11434`.
3. O OpenClaw chama o provedor `ollama` usando `/api/chat`.
4. Se `/api/chat` falhar, o proxy tenta `/api/generate`.
5. Se o Ollama ainda falhar, a cascata do OpenClaw segue para Groq, Gemini e OpenRouter.

Logs esperados no Render:

```text
OLLAMA LOCAL HABILITADO
OLLAMA_BASE_URL configurado no Render
OLLAMA_MODEL selecionado: qwen2.5:14b
PRIMARY_MODEL selecionado: ollama/qwen2.5:14b
FALLBACK_MODEL disponivel: groq/llama-3.3-70b-versatile
```

## Como testar no Telegram

1. Confirmar no Render que o deploy terminou sem erro.
2. Abrir os logs do servico `openclaw-douglas`.
3. Enviar uma mensagem simples ao bot do Telegram.
4. Confirmar nos logs se apareceu `usando Ollama local`.
5. Se aparecer `fallback acionado` ou erro de conexao, verificar se o tunnel ainda esta ativo e se `OLLAMA_BASE_URL` esta atualizado.
