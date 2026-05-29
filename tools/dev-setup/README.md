# Dev setup Windows

Este kit prepara e diagnostica o ambiente de desenvolvimento Windows para IA_DELEGACIA/OpenClaw sem alterar a configuracao de producao.

## Objetivo

- Diagnosticar ferramentas locais de desenvolvimento.
- Registrar relatorios em `logs/dev-setup`.
- Oferecer instalacao assistida, sempre com confirmacao por grupo.
- Evitar qualquer alteracao em tokens, Render, Ollama, modelos, Telegram ou configuracao de producao.

## Ordem recomendada

1. Rodar o diagnostico.
2. Ler o relatorio gerado.
3. Corrigir Python aliases, se necessario.
4. Rodar a instalacao assistida apenas para grupos realmente necessarios.
5. Preparar WSL2 Ubuntu com `tools/wsl-setup/setup_wsl_ubuntu.sh`, se o desenvolvimento tambem ocorrer no Linux.
6. Fechar e reabrir terminal.
7. Rodar o diagnostico novamente.
8. Testar OpenClaw/Ollama.

## Rodar diagnostico

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\dev-setup\verificar_ambiente_dev.ps1
```

O relatorio sera criado em:

```text
logs/dev-setup/RELATORIO_AMBIENTE_DEV_<data>.md
```

## Rodar instalacao assistida

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\dev-setup\instalar_ferramentas_dev.ps1
```

O script pergunta antes de cada grupo:

- ferramentas basicas: PowerShell 7, Windows Terminal, VS Code, 7-Zip;
- dev: Python 3.12, uv, Docker Desktop;
- terminal: ripgrep, fd, jq, FFmpeg;
- node: pnpm, yarn.

Nada e instalado sem confirmacao.

## Cuidados em maquina de producao

- Nao reiniciar sem necessidade.
- Nao instalar ferramentas durante atendimento ou uso operacional.
- Nao mexer em tokens.
- Nao mexer em Render.
- Nao mexer na configuracao do Ollama.
- Nao alterar modelo principal do OpenClaw.
- Nao fechar processos de IA sem autorizacao.

## Testes apos instalacoes

Depois de instalar ferramentas, feche e reabra o terminal e rode:

```powershell
git --version
node --version
npm --version
python --version
py --version
docker --version
ollama --version
ollama list
```

Se o PC estiver rodando Ollama local, valide tambem a resposta via OpenClaw/Telegram somente depois de confirmar que o servico de producao no Render esta estavel.

## Kits relacionados

- `tools/wsl-setup`: preparo e diagnostico do Ubuntu no WSL2.
- `tools/notebook-client`: cliente simples para testar Ollama local/remoto.
- `tools/final-expediente`: checklist operacional antes de sair.
- `docs/cloudflare-tunnel-definitivo`: plano de migracao do quick tunnel temporario para tunnel definitivo.
