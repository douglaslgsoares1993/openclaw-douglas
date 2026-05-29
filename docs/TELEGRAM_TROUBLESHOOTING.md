# Telegram troubleshooting

Este guia diagnostica o canal Telegram do `openclaw-douglas` sem inserir token real no repositorio e sem imprimir o token completo em logs.

## Token no BotFather

1. Abra conversa com `@BotFather`.
2. Use `/mybots`.
3. Selecione o bot correto.
4. Use `API Token` para visualizar ou regenerar o token.

Formato esperado:

```text
<id_numerico_do_bot>:<segredo_do_token>
```

O token normalmente contem `:` entre o identificador numerico e o segredo.

## Variaveis aceitas no Render

O entrypoint aceita estes nomes, em ordem de prioridade:

```text
TELEGRAM_BOT_TOKEN
TELEGRAM_TOKEN
BOT_TOKEN
```

Configure preferencialmente:

```text
TELEGRAM_BOT_TOKEN=<token do BotFather>
```

Tambem manter no Render:

```text
OLLAMA_BASE_URL=https://friendship-anticipated-monitors-lows.trycloudflare.com
OLLAMA_MODEL=qwen2.5:14b
PRIMARY_MODEL=ollama/qwen2.5:14b
FALLBACK_MODEL=groq/llama-3.3-70b-versatile
```

## Logs esperados no Render

O deploy deve imprimir diagnostico seguro:

```text
TELEGRAM_TOKEN_PRESENTE=sim
TELEGRAM_TOKEN_LENGTH=<quantidade>
TELEGRAM_TOKEN_PREFIX=<primeiros 5 caracteres>
TELEGRAM_TOKEN_HAS_COLON=sim
TELEGRAM getMe OK
username: <usuario_do_bot>
```

Se `TELEGRAM_TOKEN_PRESENTE=nao`, a variavel nao chegou ao container.

## Script local de diagnostico

No PowerShell:

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\telegram\telegram_diagnostico.ps1
```

O script pede o token via `Read-Host`, nao salva em arquivo e nao imprime o token completo.

Ele executa:

- `getMe`
- `getWebhookInfo`
- opcionalmente `deleteWebhook?drop_pending_updates=false`

## Interpretacao de erros

`401 Unauthorized`

Token invalido, token com espaco/quebra de linha, bot regenerado no BotFather ou variavel errada no Render.

`404 Not Found`

URL da API montada incorretamente, token vazio, token colado no lugar errado ou metodo escrito errado.

`409 Conflict`

Conflito entre webhook e polling, ou outra instancia consumindo updates do mesmo bot.

## Limpar webhook

Se houver webhook configurado e o OpenClaw usa polling, limpe o webhook:

```text
deleteWebhook?drop_pending_updates=false
```

Use o script `tools/telegram/telegram_diagnostico.ps1` e responda `s` quando ele perguntar se deseja limpar.

## Teste apos deploy

1. Confirmar que o deploy do Render terminou.
2. Confirmar nos logs `TELEGRAM getMe OK`.
3. Enviar mensagem ao bot no Telegram.
4. Conferir se o gateway do OpenClaw registrou atividade do canal.
5. Se nao responder, rodar `getWebhookInfo` e verificar conflitos `409`, webhook ativo ou token ausente.
