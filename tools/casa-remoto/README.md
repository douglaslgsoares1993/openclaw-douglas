# Casa remoto

## Fluxos

```text
Casa -> Chrome Remote Desktop -> PC Delegacia -> Ollama/tunnel
Casa -> notebook-client -> quick tunnel -> Ollama
```

## Arquivos

- `CHECKLIST_CASA.md`: roteiro para continuar de casa.
- `recuperar_tunnel_quick.ps1`: assistente para recriar quick tunnel no PC da Delegacia.
- `atualizar_url_notebook_client.ps1`: atualiza exemplos de URL dos scripts com backup.

## Limitações

- Quick tunnel e temporario.
- Render suspenso nao impede acesso direto ao Ollama.
- Sem Cloudflare Access, evite dados sensiveis.
- Chrome Remote Desktop e administracao remota, nao interface para colegas.

## Proximos passos

1. Validar acesso de casa.
2. Migrar para tunnel nomeado.
3. Proteger com Cloudflare Access.
4. Subir Open WebUI local.
5. Resolver hospedagem estavel do OpenClaw/Telegram.
