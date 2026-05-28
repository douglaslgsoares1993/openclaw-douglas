#!/bin/bash
set -e

# Escreve config do openclaw a partir das env vars
mkdir -p /root/.openclaw/agents/main/agent

cat > /root/.openclaw/openclaw.json << EOF
{
  "agents": {
    "defaults": {
      "workspace": "/root/.openclaw/workspace",
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
      "mode": "token"
    }
  },
  "channels": {
    "telegram": {
      "accounts": {
        "openclaw": {
          "token": "${TELEGRAM_BOT_TOKEN}",
          "dmPolicy": "allowlist",
          "allowFrom": ["5751936175"],
          "routing": {
            "agents": ["main"]
          }
        }
      }
    }
  }
}
EOF

cat > /root/.openclaw/agents/main/agent/auth-profiles.json << EOF
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

# Inicia o gateway
exec openclaw gateway run --port 10000 --bind lan
