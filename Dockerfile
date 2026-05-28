FROM node:22-slim

WORKDIR /app

RUN npm install -g openclaw

RUN mkdir -p /root/.openclaw/workspace     /root/.openclaw/agents/main/agent     /root/.openclaw/agents/main/sessions

COPY workspace/ /root/.openclaw/workspace/
COPY agent/ /root/.openclaw/agents/main/agent/

EXPOSE 18789

CMD ["openclaw", "gateway", "run", "--bind", "lan", "--port", "18789"]
