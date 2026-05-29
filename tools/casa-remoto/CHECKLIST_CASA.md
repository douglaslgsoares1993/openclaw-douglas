# Checklist casa remoto

## Objetivo

Continuar o trabalho da IA_DELEGACIA/OpenClaw de casa, usando o PC da Delegacia via Chrome Remote Desktop e o Ollama local exposto temporariamente por Cloudflare quick tunnel.

## Passos

1. Acessar o PC da Delegacia pelo Chrome Remote Desktop.
2. Conferir se a janela do `cloudflared` continua aberta.
3. Testar a URL publica atual:

```powershell
curl.exe https://don-pike-suggestions-reveals.trycloudflare.com/api/tags
```

4. No notebook, rodar:

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\notebook-client\teste_ia_delegacia.ps1 -BaseUrl "https://don-pike-suggestions-reveals.trycloudflare.com" -Model "qwen2.5:14b"
```

5. Para conversar diretamente:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\notebook-client\chat_ia_delegacia.ps1 -BaseUrl "https://don-pike-suggestions-reveals.trycloudflare.com" -Model "qwen2.5:14b"
```

## Se a URL cair

1. Entrar pelo Chrome Remote Desktop.
2. Recriar o quick tunnel com `tools/casa-remoto/recuperar_tunnel_quick.ps1`.
3. Copiar a nova URL `https://...trycloudflare.com`.
4. Atualizar os scripts do notebook com `tools/casa-remoto/atualizar_url_notebook_client.ps1`.

## Cuidado

- Nao usar dados sensiveis enquanto o tunnel nao estiver protegido.
- Quick tunnel e temporario e pode mudar.
- Render suspenso nao impede uso direto do Ollama pelos scripts.
- Nao inserir tokens em arquivos.
