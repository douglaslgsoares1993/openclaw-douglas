# Notebook client - IA_DELEGACIA

Clientes simples em PowerShell para testar o Ollama local/remoto a partir do notebook ou de outra maquina autorizada.

## Arquivos

- `teste_ia_delegacia.ps1`: teste unico de `/api/tags` e `/api/generate`.
- `chat_ia_delegacia.ps1`: chat simples em loop.

## URL de exemplo

```text
https://don-pike-suggestions-reveals.trycloudflare.com
```

Esta URL e apenas exemplo configuravel do quick tunnel atual. Ela pode mudar.

## Teste unico

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\notebook-client\teste_ia_delegacia.ps1 -BaseUrl "https://don-pike-suggestions-reveals.trycloudflare.com" -Model "qwen2.5:14b"
```

## Chat

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\notebook-client\chat_ia_delegacia.ps1 -BaseUrl "https://don-pike-suggestions-reveals.trycloudflare.com" -Model "qwen2.5:14b"
```

Comandos dentro do chat:

- `status`: lista modelos.
- `modelo`: troca o modelo usado no loop.
- `sair`: encerra.

## Cuidados

- Nao usar dados reais sensiveis.
- Nao salvar tokens.
- Nao usar `/v1`; estes scripts usam API nativa do Ollama.
- Se receber 403, verificar Cloudflare Access/tunnel.
- Se receber 404, verificar URL ou endpoint.
