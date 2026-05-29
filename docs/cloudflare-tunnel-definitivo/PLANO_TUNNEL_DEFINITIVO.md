# Plano de tunnel definitivo

## Objetivo

Substituir o quick tunnel temporario `trycloudflare.com` por um Cloudflare Tunnel nomeado, com URL estavel, controle de acesso e operacao previsivel para a IA_DELEGACIA.

## Estado atual

- Ollama roda no Windows da Delegacia.
- OpenClaw roda no Render.
- O Render usa `OLLAMA_BASE_URL` para acessar o Ollama.
- O quick tunnel e temporario: ao reiniciar, a URL pode mudar.

## Arquitetura desejada

```text
Telegram -> Render/OpenClaw -> Cloudflare Tunnel definitivo -> Ollama Windows -> qwen2.5:14b
```

## Fases

1. Criar tunnel nomeado no Cloudflare.
2. Criar DNS estavel para o tunnel.
3. Configurar `config.yml` local.
4. Proteger acesso com Cloudflare Access Service Token.
5. Atualizar `OLLAMA_BASE_URL` no Render.
6. Validar `/api/tags` e `/api/generate`.
7. Monitorar logs por pelo menos um expediente.

## Cuidados

- Nao publicar tokens no repositorio.
- Nao usar dados sensiveis em testes.
- Nao expor porta direta do Windows.
- Manter fallback Groq disponivel no OpenClaw.
- Documentar qualquer alteracao feita no Render.
