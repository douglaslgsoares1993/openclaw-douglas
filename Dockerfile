FROM node:22-slim

WORKDIR /app

RUN npm install -g openclaw

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.openclaw/workspace     /root/.openclaw/agents/main/agent     /root/.openclaw/agents/main/sessions

COPY workspace/ /root/.openclaw/workspace/
COPY agent/ /root/.openclaw/agents/main/agent/
COPY openclaw-entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s   CMD curl -f http://localhost:10000/health || exit 1

CMD ["/app/entrypoint.sh"]
