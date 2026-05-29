# CONTEXTO_OPENCLAW.md
## Documento de legado e referência para o Claude Code

> **Instruções de uso:** Antes de qualquer intervenção no OpenClaw, leia este arquivo integralmente.
> Após qualquer alteração bem-sucedida, atualize a seção correspondente.
> Nunca assuma nomes de campos - sempre consulte `openclaw config schema` antes de editar o JSON.

---

## 1. AMBIENTE

| Item | Valor |
|---|---|
| Sistema operacional | Windows 11 25H2 (Build 26200.8524) |
| Subsistema Linux | WSL2 - Ubuntu 24.04 LTS |
| Usuário Linux | douglas |
| Versão OpenClaw | 2026.5.27 (27ae826) |
| Node.js | v22.22.2 |
| npm | 10.9.7 |
| Instalação OpenClaw | `~/.npm-global/bin/openclaw` |
| Config principal | `~/.openclaw/openclaw.json` |
| Backup automático | `~/.openclaw/openclaw.json.bak` |
| Workspace | `~/.openclaw/workspace` |
| Auth profiles | `~/.openclaw/agents/main/agent/auth-profiles.json` |
| Log gateway | `/tmp/openclaw/openclaw-2026-05-28.log` |

**Como acessar o WSL a partir do Claude Code:**
```bash
wsl -d Ubuntu-24.04 bash -c "COMANDO AQUI"
# Para sessão interativa:
wsl -d Ubuntu-24.04
```

---

## 2. PROVEDORES DE LLM CONFIGURADOS

### Modelo padrão (primário)
```
groq/llama-3.3-70b-versatile
```

### Cascata de fallbacks (em ordem de prioridade)
| Ordem | Modelo | Provedor | Limite gratuito |
|---|---|---|---|
| 0º (primário quando `OLLAMA_BASE_URL` existir) | `ollama/qwen2.5:14b` | Ollama local (PC Delegacia) | Ilimitado - sem custo |
| 1º | `groq/llama-3.1-8b-instant` | Groq | ~1.400 req/dia |
| 2º | `google/gemini-2.5-flash` | Google AI Studio | 1.500 req/dia |
| 3º | `openrouter/deepseek/deepseek-v4-flash:free` | OpenRouter | 50 req/dia (sem créditos) |
| 4º | `openrouter/meta-llama/llama-3.3-70b-instruct:free` | OpenRouter | 50 req/dia (sem créditos) |

> Nota (29/05/2026): `cerebras/qwen-3-235b-a22b-instruct-2507` removido da cascata - chave atual retorna HTTP 401 "Wrong API Key". Reativar após corrigir `CEREBRAS_API_KEY`. Ollama (0º) entra só quando `OLLAMA_BASE_URL` estiver definida no Render. O modelo pode ser ajustado por `OLLAMA_MODEL`; padrão: `qwen2.5:14b`.

### Modelos adicionais configurados (disponíveis no /model picker)
- `google/gemini-2.5-pro`
- `google/gemini-3.1-flash-lite`
- `cerebras/llama3.1-8b`
- `openrouter/nvidia/nemotron-3-super-120b-a12b:free`
- `openrouter/qwen/qwen3-coder:free`
- `openrouter/qwen/qwen3-next-80b-a3b-instruct:free`

### Status de autenticação
Todas as chaves estão salvas em `auth-profiles.json`. Para verificar:
```bash
openclaw models status
```

---

## 3. CANAIS CONFIGURADOS

### Telegram
| Campo | Valor |
|---|---|
| Bot | @openclawdouglas_bot |
| Account ID interno | openclaw |
| Agente vinculado | main |
| dmPolicy | allowlist |
| allowFrom | ["5751936175"] (ID Telegram do Douglas) |
| Bot de frota (separado) | @frota15desec_bot (Render - não mexer) |

---

## 4. GATEWAY

| Campo | Valor |
|---|---|
| Modo | local |
| Porta | 18789 |
| Browser control | http://127.0.0.1:18791/ |
| Iniciar gateway | `openclaw gateway run` |
| Iniciar em background | `openclaw gateway run --detach` |
| Parar gateway | `openclaw gateway stop` |
| Ver logs | `openclaw logs` |
| Status geral | `openclaw status` |

**Importante:** Após qualquer alteração de config, reiniciar o gateway:
```bash
openclaw gateway stop && openclaw gateway run --detach
```

---

## 5. SEGURANÇA

- dmPolicy configurado como **allowlist** - só o ID 5751936175 pode usar o bot
- Após qualquer alteração de canal, reiniciar o gateway para aplicar
- Não expor a porta 18789 à internet sem autenticação
- Rodar periodicamente: `openclaw security audit --deep`
- CVE-2026-22176 - manter OpenClaw atualizado: `openclaw update`

---

## 6. COMANDOS ESSENCIAIS DE DIAGNÓSTICO

```bash
# Estado geral
openclaw status

# Modelos e auth
openclaw models status

# Verificar config sem iniciar gateway
openclaw config validate

# Reparar problemas comuns
openclaw doctor --fix

# Ver schema completo (SEMPRE consultar antes de editar JSON)
openclaw config schema

# Ver config atual
cat ~/.openclaw/openclaw.json

# Restaurar backup
cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json

# Listar agentes
openclaw agents list

# Listar skills instaladas
openclaw skills list

# Listar canais
openclaw channels status
```

---

## 7. REGRAS PARA O CLAUDE CODE

1. **Nunca assumir nomes de campos** - sempre rodar `openclaw config schema` antes de editar o JSON
2. **Sempre ler o arquivo antes de editar** - usar `cat ~/.openclaw/openclaw.json`
3. **Usar Python3 para edições JSON** - mais confiável que jq no WSL
4. **Sempre validar após edição** - rodar `openclaw config validate`
5. **Restaurar backup se validação falhar** - `cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json`
6. **Reiniciar gateway após mudanças** - configurações só aplicam após restart
7. **Usar prefixo `wsl -d Ubuntu-24.04`** em todos os comandos bash

### Template padrão para edições JSON via Python3:
```bash
wsl -d Ubuntu-24.04 python3 -c "
import json, os

config_path = os.path.expanduser('~/.openclaw/openclaw.json')
backup_path = config_path + '.bak'

# Ler arquivo atual
with open(config_path) as f:
    config = json.load(f)

# FAZER ALTERAÇÕES AQUI
# config['campo'] = valor

# Salvar
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('done')
"
```

---

## 8. PLANO DE AGENTES - STATUS

> Atualizar esta seção conforme cada agente for concluído.

### FASE 0 - Infraestrutura
| # | Agente | Status | Observações |
|---|---|---|---|
| - | WSL2 + Ubuntu 24.04 | ✅ Concluído | |
| - | OpenClaw instalado | ✅ Concluído | v2026.5.27 |
| - | Groq configurado | ✅ Concluído | Modelo primário |
| - | Gemini configurado | ✅ Concluído | 3 modelos |
| - | Cerebras configurado | ✅ Concluído | 2 modelos |
| - | OpenRouter configurado | ✅ Concluído | 5 modelos free |
| - | Telegram conectado | ✅ Concluído | @openclawdouglas_bot |
| - | Fallbacks configurados | ⏳ Em andamento | Aguardando correção schema |
| - | SOUL.md configurado | ✅ Concluído | Skills adicionadas |
| - | Skills customizadas criadas | ✅ Concluído | resenha-policial, concurso-delegado |
| 1 | Base + Auto-evolução | ⏳ Pendente | |
| 2 | Briefing Matinal | ✅ Concluído | skill briefing-matinal criada | |

### FASE 1 - Comunicação
| # | Agente | Status |
|---|---|---|
| 3 | Triagem de E-mail | ⏳ Pendente |
| 4 | Redator Institucional | ⏳ Pendente |

### FASE 2 - Trabalho Policial
| # | Agente | Status |
|---|---|---|
| 21A | Resenha de Homicídio | ⏳ Pendente |
| 21B | Resenha de Prisão | ⏳ Pendente |
| 21C | Resenha de Operação | ⏳ Pendente |
| 11 | Documentação Policial Geral | ⏳ Pendente |
| 12 | Monitor de Frota | ⏳ Pendente |
| 13 | Gestor de Prazos | ⏳ Pendente |
| 17 | Monitor Diário Oficial | ⏳ Pendente |

### FASE 3 - Concurso
| # | Agente | Status |
|---|---|---|
| 5 | Monitor de Concursos | ✅ Concluído |
| 6 | Coach Objetiva CESPE | ⏳ Pendente |
| 7 | Coach Peças Discursivas | ⏳ Pendente |
| 8 | Coach Oral | ⏳ Pendente |
| 9 | Pesquisa Jurisprudência | ⏳ Pendente |
| 10 | Flashcards Adaptativos | ⏳ Pendente |

### FASE 4 - Produtividade
| # | Agente | Status |
|---|---|---|
| 15 | Gestor de Tarefas | ⏳ Pendente |
| 16 | Resumidor de Documentos | ⏳ Pendente |
| 18 | Gestor Financeiro | ⏳ Pendente |

### FASE 5 - Avançados
| # | Agente | Status |
|---|---|---|
| 14 | OSINT | ⏳ Pendente |
| 19 | Inteligência Financeira COAF | ⏳ Pendente |
| 20 | Pesquisa Autônoma | ⏳ Pendente |

---

## 9. INFORMAÇÕES INSTITUCIONAIS

### Estrutura da 15ª DESEC
| Unidade | Município | Delegado |
|---|---|---|
| 15ª DESEC (Seccional) | Belo Jardim | Marcelo Francisco dos Santos Silva |
| 104ª DP | Belo Jardim | José Maranduba Andrade Júnior |
| 105ª DP | Pesqueira | Alyson Henrique Marques Xavier |
| 106ª DP | São Bento do Una | Jomario Gomes do Carmo |
| 108ª DP | São Caetano | Fabrício Pimentel Lourenço Lima |
| 109ª DP | Cachoeirinha | Roberto Macedo Silva |
| 110ª DP | Sanharó | Walkis Pacheco Sobreira Filho |
| 112ª DP | Tacaimbó | *Exercício acumulativo - preencher na hora* |
| 113ª DP | Alagoinha | *Exercício acumulativo - preencher na hora* |
| 114ª DP | Poção | *Exercício acumulativo - preencher na hora* |

### Regra de IC por município
- **IC de Arcoverde:** Pesqueira, Alagoinha, Poção
- **IC de Caruaru:** todos os demais municípios da seccional

### Operador principal
Douglas Leonardo Gomes Soares - Mat. 387.693-4
Agente de Polícia - 15ª DESEC/Belo Jardim

---

## 10. INFRAESTRUTURA DE DEPLOY

### Situação atual (local - temporário)
- Rodando no WSL2 do notebook de Douglas
- **Não é produção** - notebook precisa estar ligado

### Destino final (Oracle Cloud - em aprovação)
- Oracle Cloud Always Free: 4 ARM CPUs, 24 GB RAM
- Deploy via Docker
- Bot Telegram: @openclawdouglas_bot (mesmo)
- Config portável: exportar `openclaw.json` + `auth-profiles.json`

### Outros serviços relacionados
- Bot de frota: @frota15desec_bot → Render (não mexer)
- Banco de dados: Supabase
- Monitoramento: UptimeRobot

---

---

## 11. SKILLS INSTALADAS

### ClawHub (comunidade)
- capability-evolver - auto-evolução do agente
- skill-vetter - autocrítica e aprendizado
- summarize - resumo de documentos
- tavily-web-search - pesquisa web em tempo real

### Customizadas (15ª DESEC)
- resenha-policial - templates de resenha para homicídio, prisão e operação
- concurso-delegado - coach para prova objetiva, discursiva e oral

### Como instalar nova skill
```bash
# Via ClawHub
clawhub install <nome-skill>
# Via GitHub
git clone https://github.com/autor/skill ~/openclaw-douglas/skills/nome-skill
# Depois reinicia gateway
openclaw gateway stop && openclaw gateway run --detach
```

---

## 12. SERVIDOR LOCAL - HP Z2 G9 (DELEGACIA)

Status: Pendente instalação
Máquina: HP Z2 G9 Tower - i9 12ª gen, 32GB DDR5, RTX A4000 16GB VRAM
Localização: 15ª DESEC - Belo Jardim/PE
Internet: privada (não institucional PCPE)
Guia de instalação: docs/SETUP_OLLAMA_DELEGACIA.md

Modelos planejados:
- qwen2.5:14b (relatórios e resenhas)
- llama3.1:8b (tarefas rápidas)
- mistral:7b (triagem)
- nomic-embed-text (memória vetorial)

Exposição: Cloudflare Tunnel → OLLAMA_BASE_URL no Render

---

*Última atualização: 28/05/2026*
*Versão do documento: 1.2*
