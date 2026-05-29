# Checklist de migracao para tunnel definitivo

- [ ] Confirmar Ollama local ativo no Windows.
- [ ] Confirmar `ollama list` com `qwen2.5:14b`.
- [ ] Criar tunnel nomeado no Cloudflare.
- [ ] Criar DNS estavel.
- [ ] Criar `config.yml` local fora do repositorio, se contiver caminho real sensivel.
- [ ] Testar `cloudflared tunnel run`.
- [ ] Testar `/api/tags` pela URL publica.
- [ ] Testar `/api/generate` com prompt ficticio.
- [ ] Atualizar `OLLAMA_BASE_URL` no Render.
- [ ] Confirmar `PRIMARY_MODEL=ollama/qwen2.5:14b`.
- [ ] Confirmar `FALLBACK_MODEL=groq/llama-3.3-70b-versatile`.
- [ ] Fazer redeploy.
- [ ] Testar bot no Telegram.
- [ ] Monitorar logs por um expediente.
- [ ] Planejar Cloudflare Access Service Token.
