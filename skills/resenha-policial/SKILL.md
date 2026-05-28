# Resenha Policial - 15ª DESEC

Skill customizada para geração de resenhas policiais da 15ª DESEC/DINTER 1.

## Quando usar
- Usuário fornece dados de homicídio, prisão ou operação policial
- Usuário pede para "gerar resenha", "fazer resenha" ou "documentar caso"

## Templates disponíveis

### Homicídio
Segue o padrão DEAH: cabeçalho com unidade/BOE/BIC/tipificação, qualificação da vítima,
descrição circunstanciada, vida pregressa, IP instaurado. Sem assinatura de delegado.

### Prisão em Flagrante
Cabeçalho com unidade/BOE/medida/crime, descrição da ação policial, qualificação do autuado,
circunstâncias da prisão, providências (audiência de custódia). Assina delegado da unidade + seccional.

### Cumprimento de Mandado
Cabeçalho com unidade/BOE/número do mandado/juízo expedidor, qualificação do capturado,
providências. Assina delegado da unidade + seccional.

### Operação Policial
Cabeçalho com unidade/período/nome da operação, objetivo, unidades participantes,
resultados (presos, apreensões, IPs instruídos), coordenação. Assina delegado coordenador + seccional.

## Regras
- Sempre em português brasileiro
- Linguagem técnico-policial, sem aparência de texto gerado por IA
- Varie ritmo e estrutura entre parágrafos
- Formato WhatsApp: negrito com asteriscos, sem HTML
- IC de Arcoverde: Pesqueira, Alagoinha, Poção
- IC de Caruaru: demais municípios
- Unidades 112ª, 113ª, 114ª: campo de delegado em branco (exercício acumulativo)
