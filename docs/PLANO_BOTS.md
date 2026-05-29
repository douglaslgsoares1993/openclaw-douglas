# Plano de Bots - 15ª DESEC

## Visão geral

Todos os bots da 15ª DESEC são agentes do OpenClaw, acessados via @openclawdouglas_bot no Telegram. Não são bots separados - são skills e contextos diferentes dentro do mesmo agente Claw.

## Bots planejados

### Bot Administrativo
Minutas de ofícios, despachos, CIs, memorandos. Padronização de linguagem institucional. Organização de tarefas e prazos.

### Bot Redação Policial
Resenhas de homicídio, prisão e operação. Termos de declarações. BOEs. BICs. Sempre exige revisão humana antes do uso oficial.

### Bot Investigativo
Uso restrito. Apenas dados fictícios, anonimizados ou formalmente autorizados. Organização de linhas do tempo, extração de entidades, preparação de análises para revisão humana. Nunca produz conclusão probatória sem validação.

### Bot SFI/Obras
Apoio a cronogramas, vistorias, relatórios técnicos, controle de pendências e prazos das 9 circunscrições.

### Bot Consulta Documental
RAG local - consulta à base documental da seccional. Responde com citação de fonte. Integra com servidor Ollama da delegacia para dados internos.

### Bot Suporte Técnico
Apoio a scripts Python, diagnóstico de sistemas, manutenção da infraestrutura IA_DELEGACIA.

### Bot Concurso
Coach para concurso de Delegado - questões CESPE, peças discursivas, simulação oral, flashcards, jurisprudência.

## Regras gerais
- Revisão humana obrigatória para qualquer documento oficial
- Dados sensíveis processados apenas pelo Ollama local
- Logs de uso registrados
- Nenhuma decisão delegada integralmente à IA
