# WSL setup - IA_DELEGACIA/OpenClaw

Este diretório prepara e diagnostica o Ubuntu no WSL2 para desenvolvimento local do projeto IA_DELEGACIA/OpenClaw.

## Arquivos

- `setup_wsl_ubuntu.sh`: instalador assistido para ferramentas Linux de desenvolvimento.
- `verificar_wsl.sh`: diagnostico WSL e teste de acesso ao Ollama.
- `ACESSO_OLLAMA_WINDOWS.md`: guia para acessar o Ollama do Windows a partir do WSL.

## Ordem recomendada

1. Abrir Ubuntu no WSL2.
2. Entrar no repositorio.
3. Rodar o diagnostico.
4. Rodar o setup apenas se faltarem ferramentas.
5. Testar acesso ao Ollama local do Windows.

## Diagnostico

```bash
cd /mnt/c/openclaw-douglas
bash tools/wsl-setup/verificar_wsl.sh
```

O relatorio sera gerado em:

```text
logs/wsl-setup/
```

## Instalacao assistida

```bash
cd /mnt/c/openclaw-douglas
bash tools/wsl-setup/setup_wsl_ubuntu.sh
```

O script pergunta antes de cada grupo. Nada e instalado sem confirmacao.

## Variaveis uteis

```bash
export OLLAMA_BASE_URL=http://localhost:11434
export OLLAMA_MODEL=qwen2.5:14b
```

Para testar tunnel temporario:

```bash
export OLLAMA_BASE_URL=https://don-pike-suggestions-reveals.trycloudflare.com
```

Essa URL e exemplo configuravel e pode mudar quando o quick tunnel for reiniciado.
