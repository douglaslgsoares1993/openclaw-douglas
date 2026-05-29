# Seguranca com Cloudflare Access Service Token

## Objetivo

Proteger o endpoint publico do Ollama para que apenas clientes autorizados acessem o tunnel definitivo.

## Diretrizes

- Criar Service Token no Cloudflare Access.
- Guardar `CF-Access-Client-Id` e `CF-Access-Client-Secret` somente em cofre/Render env vars.
- Nao gravar tokens no repositorio.
- Nao colar tokens em documentacao, issues ou logs.
- Rotacionar tokens se houver suspeita de exposicao.

## Render

Quando o OpenClaw/proxy precisar usar Access, configurar variaveis secretas no Render, por exemplo:

```text
CF_ACCESS_CLIENT_ID=<valor no Render>
CF_ACCESS_CLIENT_SECRET=<valor no Render>
```

O codigo atual nao exige esses headers. Esta etapa e plano de endurecimento para o tunnel definitivo.

## Validacao

- Requisicoes sem token devem falhar.
- Requisicoes com token devem acessar `/api/tags`.
- O bot deve responder no Telegram apos o redeploy.
