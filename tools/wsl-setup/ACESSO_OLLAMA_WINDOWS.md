# Acesso ao Ollama Windows pelo WSL2

## Cenário

- Ollama roda no Windows.
- Desenvolvimento pode ocorrer no Ubuntu/WSL2.
- O modelo padrao e `qwen2.5:14b`.

## Teste simples

No WSL:

```bash
curl http://localhost:11434/api/tags
```

Se funcionar, o WSL consegue acessar o Ollama do Windows via `localhost`.

## Teste de geração

```bash
curl -s http://localhost:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen2.5:14b","prompt":"Responda em portugues: WSL conectado ao Ollama.","stream":false}' | jq
```

## Se localhost não funcionar

Descobrir o IP do Windows visto pelo WSL:

```bash
cat /etc/resolv.conf | grep nameserver
```

Testar substituindo o IP:

```bash
curl http://IP_DO_WINDOWS:11434/api/tags
```

## Tunnel temporário

Para testar pelo tunnel temporario:

```bash
export OLLAMA_BASE_URL=https://don-pike-suggestions-reveals.trycloudflare.com
curl "$OLLAMA_BASE_URL/api/tags"
```

URLs `trycloudflare.com` sao temporarias. Ao reiniciar o quick tunnel, atualize a variavel.

## Cuidados

- Nao colocar tokens em arquivos.
- Nao alterar firewall ou servicos por este guia.
- Nao usar dados reais sensiveis nos testes.
- Nao alterar o modelo principal do Render.
