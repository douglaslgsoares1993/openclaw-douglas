FROM node:22-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*

# Instala OpenClaw e ClawHub CLI
RUN npm install -g openclaw clawhub@latest

# Instala skills essenciais
RUN clawhub install capability-evolver || npx clawhub@latest install capability-evolver || true
RUN clawhub install skill-vetter || npx clawhub@latest install skill-vetter || true
RUN clawhub install summarize || npx clawhub@latest install summarize || true
RUN clawhub install tavily-web-search || npx clawhub@latest install tavily-web-search || true

# Cria estrutura de diretorios
RUN mkdir -p /root/.openclaw/workspace \
    /root/.openclaw/agents/main/agent \
    /root/.openclaw/agents/main/sessions \
    /root/.openclaw/skills

# Copia arquivos de configuracao
COPY workspace/ /root/.openclaw/workspace/
COPY agent/ /root/.openclaw/agents/main/agent/
COPY openclaw-entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

COPY skills/ /root/.openclaw/skills/

EXPOSE 10000

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s \
  CMD curl -f http://localhost:10000/health || exit 1

CMD ["/app/entrypoint.sh"]
