#!/bin/bash
set -e

CONFIG_DIR="/root/.openclaw"
mkdir -p "$CONFIG_DIR/agents/main/agent" "$CONFIG_DIR/workspace" "$CONFIG_DIR/agents/main/sessions"

cat > "$CONFIG_DIR/openclaw.json" << EOF
{
  "agents": {
    "defaults": {
      "workspace": "$CONFIG_DIR/workspace",
      "model": {
        "primary": "groq/llama-3.3-70b-versatile",
        "fallbacks": [
          "cerebras/qwen-3-235b-a22b-instruct-2507",
          "google/gemini-2.5-flash",
          "openrouter/deepseek/deepseek-v4-flash:free",
          "openrouter/meta-llama/llama-3.3-70b-instruct:free"
        ]
      }
    }
  },
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
echo "=== OPENCLAW VERSION ==="
openclaw --version
echo "=== VALIDANDO CONFIG ==="
openclaw config validate 2>&1 || true
echo "=== INICIANDO GATEWAY ==="

exec openclaw gateway run --port 10000 --bind lan
