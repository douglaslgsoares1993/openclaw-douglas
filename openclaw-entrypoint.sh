#!/bin/bash
set -e

CONFIG_DIR="/root/.openclaw"
mkdir -p "$CONFIG_DIR/agents/main/agent" "$CONFIG_DIR/workspace" "$CONFIG_DIR/agents/main/sessions"

# Monta a cascata de modelos dinamicamente.
# cerebras removido: chave atual retorna HTTP 401 "Wrong API Key".
DEFAULT_EXTERNAL_PRIMARY="groq/llama-3.3-70b-versatile"
EXTERNAL_FALLBACKS='"groq/llama-3.1-8b-instant",
          "google/gemini-2.5-flash",
          "openrouter/deepseek/deepseek-v4-flash:free",
          "openrouter/meta-llama/llama-3.3-70b-instruct:free"'

MODELS_CONFIG=""
OLLAMA_MODEL_RESOLVED="${OLLAMA_MODEL:-qwen2.5:14b}"
DEFAULT_OLLAMA_PRIMARY="ollama/${OLLAMA_MODEL_RESOLVED}"
FALLBACK_MODEL_RESOLVED="${FALLBACK_MODEL:-$DEFAULT_EXTERNAL_PRIMARY}"
OLLAMA_API_KEY_RESOLVED="${OLLAMA_API_KEY:-ollama-local}"
OLLAMA_PROXY_PORT="${OLLAMA_PROXY_PORT:-11434}"

build_fallbacks() {
  if [ "$FALLBACK_MODEL_RESOLVED" = "$PRIMARY_MODEL_RESOLVED" ]; then
    FALLBACKS="$EXTERNAL_FALLBACKS"
  else
    FALLBACKS='"'"$FALLBACK_MODEL_RESOLVED"'",
          '"$EXTERNAL_FALLBACKS"
  fi
}

# Se OLLAMA_BASE_URL estiver definida, Ollama local vira provedor primario.
# A cascata atual permanece como fallback de producao.
if [ -n "$OLLAMA_BASE_URL" ]; then
  PRIMARY_MODEL_RESOLVED="${PRIMARY_MODEL:-$DEFAULT_OLLAMA_PRIMARY}"
  build_fallbacks
  OPENCLAW_OLLAMA_BASE_URL="http://127.0.0.1:${OLLAMA_PROXY_PORT}"

  echo "=== OLLAMA LOCAL HABILITADO ==="
  echo "OLLAMA_BASE_URL configurado no Render"
  echo "OLLAMA_MODEL selecionado: ${OLLAMA_MODEL_RESOLVED}"
  echo "PRIMARY_MODEL selecionado: ${PRIMARY_MODEL_RESOLVED}"
  echo "FALLBACK_MODEL disponivel: ${FALLBACK_MODEL_RESOLVED}"
  echo "Proxy Ollama interno: ${OPENCLAW_OLLAMA_BASE_URL}"
  echo "Fallback se Ollama falhar: ${FALLBACK_MODEL_RESOLVED} -> demais provedores configurados"

  node /app/ollama-proxy.js &

  MODELS_CONFIG=',
  "models": {
    "providers": {
      "ollama": {
        "api": "ollama",
        "baseUrl": "'"$OPENCLAW_OLLAMA_BASE_URL"'",
        "timeoutSeconds": 300,
        "models": [
          {
            "id": "'"$OLLAMA_MODEL_RESOLVED"'",
            "name": "'"$OLLAMA_MODEL_RESOLVED"'",
            "input": ["text"],
            "params": {
              "keep_alive": "15m"
            }
          }
        ]
      }
    }
  }'
else
  PRIMARY_MODEL_RESOLVED="${PRIMARY_MODEL:-$DEFAULT_EXTERNAL_PRIMARY}"
  if [[ "$PRIMARY_MODEL_RESOLVED" == ollama/* ]]; then
    echo "PRIMARY_MODEL aponta para Ollama, mas OLLAMA_BASE_URL nao esta definida; usando ${DEFAULT_EXTERNAL_PRIMARY}"
    PRIMARY_MODEL_RESOLVED="$DEFAULT_EXTERNAL_PRIMARY"
  fi
  build_fallbacks
  echo "OLLAMA_BASE_URL nao definida - usando provedores atuais"
  echo "PRIMARY_MODEL selecionado: ${PRIMARY_MODEL_RESOLVED}"
  echo "FALLBACK_MODEL disponivel: ${FALLBACK_MODEL_RESOLVED}"
fi

cat > "$CONFIG_DIR/openclaw.json" << EOF
{
  "agents": {
    "defaults": {
      "workspace": "$CONFIG_DIR/workspace",
      "model": {
        "primary": "$PRIMARY_MODEL_RESOLVED",
        "fallbacks": [
          $FALLBACKS
        ]
      }
    }
  }$MODELS_CONFIG,
  "gateway": {
    "mode": "local",
    "port": 10000,
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    }
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "allowlist",
      "allowFrom": ["5751936175"]
    }
  }
}
EOF

cat > "$CONFIG_DIR/agents/main/agent/auth-profiles.json" << EOF
{
  "version": 1,
  "profiles": {
    "ollama:default": { "apiKey": "${OLLAMA_API_KEY_RESOLVED}" },
    "groq:default": { "apiKey": "${GROQ_API_KEY}" },
    "google:default": { "apiKey": "${GOOGLE_API_KEY}" },
    "cerebras:default": { "apiKey": "${CEREBRAS_API_KEY}" },
    "openrouter:default": { "apiKey": "${OPENROUTER_API_KEY}" }
  }
}
EOF

export OPENCLAW_CONFIG_PATH="$CONFIG_DIR/openclaw.json"
export OPENCLAW_STATE_DIR="$CONFIG_DIR"

echo "=== CONFIG GERADO ==="
cat "$CONFIG_DIR/openclaw.json"
echo "=== AUTH PROFILES ==="
cat "$CONFIG_DIR/agents/main/agent/auth-profiles.json" | sed 's/"apiKey": "[^"]*"/"apiKey": "***"/g'
if [ -n "$OLLAMA_BASE_URL" ]; then
  echo "=== OLLAMA PREFLIGHT ==="
  OLLAMA_PREFLIGHT_OK=0
  for attempt in 1 2 3 4 5; do
    if curl -fsS "http://127.0.0.1:${OLLAMA_PROXY_PORT}/api/tags" >/dev/null; then
      OLLAMA_PREFLIGHT_OK=1
      break
    fi
    sleep 1
  done
  if [ "$OLLAMA_PREFLIGHT_OK" = "1" ]; then
    echo "Ollama acessivel via proxy interno"
  else
    echo "Erro de conexao com Ollama - fallback do OpenClaw sera acionado em runtime se o modelo primario falhar"
  fi
fi
echo "=== OPENCLAW VERSION ==="
openclaw --version
echo "=== VALIDANDO CONFIG ==="
openclaw config validate 2>&1 || true
echo "=== INICIANDO GATEWAY ==="

exec openclaw gateway run --port 10000 --bind lan
