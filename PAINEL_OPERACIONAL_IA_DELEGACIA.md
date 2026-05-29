# Painel operacional IA_DELEGACIA/OpenClaw

## Estado atual

- Windows 11 Pro e a estacao principal de IA local.
- WSL2 Ubuntu esta disponivel para desenvolvimento Linux.
- Ollama roda no Windows.
- Modelo principal desejado: `ollama/qwen2.5:14b`.
- Fallback principal: `groq/llama-3.3-70b-versatile`.
- OpenClaw roda no Render.
- Telegram esta em diagnostico.
- Cloudflare quick tunnel e temporario.

## Integracoes

```text
Telegram -> Render/OpenClaw -> Cloudflare Tunnel -> Ollama Windows -> modelos locais
Notebook/WSL -> ferramentas de desenvolvimento -> GitHub -> Render
```

## Checklist de saida

Rodar:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\final-expediente\checklist_final_expediente.ps1 -PublicBaseUrl https://don-pike-suggestions-reveals.trycloudflare.com
```

Resultado esperado:

```text
PODE SAIR COM SEGURANCA
```

Se aparecer `ATENCAO`, revisar o relatorio em `logs/final-expediente`.

## Riscos

- Quick tunnel muda de URL ao reiniciar.
- Token Telegram incorreto impede resposta do bot.
- Cloudflare Access mal configurado pode bloquear o Render.
- Modelo local indisponivel aciona fallback externo.
- Reiniciar a maquina pode derrubar Ollama e tunnel.

## Proximas missoes

- Estabilizar Telegram.
- Migrar quick tunnel para tunnel definitivo.
- Testar cliente notebook.
- Validar WSL2 para desenvolvimento.
- Criar rotina de backup operacional.
- Avaliar Cloudflare Access Service Token.

## Comandos uteis

```powershell
ollama list
ollama run qwen2.5:14b
nvidia-smi
powershell.exe -ExecutionPolicy Bypass -File .\tools\dev-setup\verificar_ambiente_dev.ps1
powershell.exe -ExecutionPolicy Bypass -File .\tools\notebook-client\teste_ia_delegacia.ps1
powershell.exe -ExecutionPolicy Bypass -File .\tools\final-expediente\checklist_final_expediente.ps1
```

No WSL:

```bash
bash tools/wsl-setup/verificar_wsl.sh
```

## Arquitetura Windows + WSL + Ollama + Render + Telegram

- Windows hospeda Ollama e GPU NVIDIA.
- WSL2 fornece ambiente Linux para desenvolvimento e automacoes.
- Cloudflare Tunnel publica temporariamente ou definitivamente o Ollama.
- Render executa OpenClaw 24h.
- Telegram e canal operacional do bot.
- Groq/OpenRouter permanecem como fallback externo.

## Modo casa

- Acessar o PC da Delegacia pelo Chrome Remote Desktop.
- Conferir se Ollama e cloudflared continuam ativos.
- Testar `https://don-pike-suggestions-reveals.trycloudflare.com/api/tags`.
- Usar `tools/notebook-client` para acesso direto ao Ollama, sem depender do Render.
- Se a URL cair, recriar o quick tunnel com `tools/casa-remoto/recuperar_tunnel_quick.ps1`.

## Acesso remoto via Chrome Remote Desktop

Chrome Remote Desktop e o caminho administrativo para mexer no PC sem presenca fisica. Nao e canal de uso por colegas nem substitui uma interface web protegida.

## Uso direto sem Render

Com Render suspenso, o fluxo direto fica:

```text
Notebook de casa -> quick tunnel -> Ollama Windows -> qwen2.5:14b
```

## Open WebUI futuro

Preparado em `tools/open-webui-local`. Deve iniciar localmente em `http://localhost:3000` e conectar no Ollama por `host.docker.internal:11434`.

## Memoria/RAG

Documentacao inicial em `docs/memoria-e-rag`. O modelo nao aprende sozinho; memoria vem de historico, perfis, RAG e banco local controlado.

## Uso por colegas

Documentacao inicial em `docs/uso-por-colegas`. Comecar por uso administrativo, com politica clara, revisao humana e sem dados sigilosos.

## Pendencias criticas

1. Tunnel definitivo.
2. URL fixa.
3. Cloudflare Access.
4. Hospedagem estavel para bot.
5. Politica de dados.
