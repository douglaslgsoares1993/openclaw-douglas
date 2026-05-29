#!/usr/bin/env bash
set -euo pipefail

# Diagnostico WSL: gera relatorio local e nao instala nada.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="$ROOT_DIR/logs/wsl-setup"
STAMP="$(date +%Y%m%d_%H%M%S)"
REPORT="$LOG_DIR/RELATORIO_WSL_$STAMP.md"
OLLAMA_URL="${OLLAMA_BASE_URL:-http://localhost:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:14b}"

mkdir -p "$LOG_DIR"

line() {
  printf '%s\n' "${1:-}" >> "$REPORT"
}

tool_line() {
  local name="$1"
  local cmd="$2"
  shift 2 || true
  if command -v "$cmd" >/dev/null 2>&1; then
    local output
    output="$("$cmd" "$@" 2>&1 | head -n 1 || true)"
    line "| $name | OK | ${output:-Encontrado} | $(command -v "$cmd") |"
  else
    line "| $name | Pendente | Nao encontrado | |"
  fi
}

line "# Relatorio WSL - IA_DELEGACIA/OpenClaw"
line
line "Gerado em: $(date -Is)"
line "Repositorio: $ROOT_DIR"
line "Ollama URL testada: $OLLAMA_URL"
line "Modelo testado: $OLLAMA_MODEL"
line

line "## Sistema"
line
line '```text'
cat /etc/os-release >> "$REPORT" 2>/dev/null || true
uname -a >> "$REPORT" 2>/dev/null || true
line '```'
line

line "## Ferramentas"
line
line "| Ferramenta | Status | Versao/Saida | Caminho |"
line "| --- | --- | --- | --- |"
tool_line "Git" git --version
tool_line "Node.js" node --version
tool_line "npm" npm --version
tool_line "pnpm" pnpm --version
tool_line "Python" python3 --version
tool_line "pip" pip3 --version
tool_line "uv" uv --version
tool_line "Docker" docker --version
tool_line "curl" curl --version
tool_line "jq" jq --version
tool_line "ripgrep" rg --version
tool_line "fd" fd --version
line

line "## Ollama tags"
line
line '```text'
if curl -fsS --max-time 10 "$OLLAMA_URL/api/tags" >> "$REPORT" 2>&1; then
  line
else
  line
  line "Falha ao acessar $OLLAMA_URL/api/tags"
fi
line '```'
line

line "## Teste de geracao"
line
line '```text'
payload="$(jq -n --arg model "$OLLAMA_MODEL" --arg prompt "Responda em portugues em uma frase curta: WSL conectado ao Ollama." '{model:$model,prompt:$prompt,stream:false}')"
if curl -fsS --max-time 120 -H 'Content-Type: application/json' -d "$payload" "$OLLAMA_URL/api/generate" >> "$REPORT" 2>&1; then
  line
else
  line
  line "Falha no teste de geracao com $OLLAMA_MODEL"
fi
line '```'

printf 'Relatorio gerado em: %s\n' "$REPORT"
