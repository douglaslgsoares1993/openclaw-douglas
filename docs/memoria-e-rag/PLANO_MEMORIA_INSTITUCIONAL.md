# Plano de memoria institucional - 15 DESEC

## Bases propostas

- Base administrativa geral.
- Base SFI.
- Base SEI/modelos.
- Base manutencao predial.
- Base tutoriais internos.
- Base investigativa isolada em fase posterior.

## Regras

- Nao misturar investigacao sigilosa com base comum.
- Classificar documentos antes de ingestao.
- Registrar origem, data e responsavel.
- Permitir exclusao e revisao.
- Evitar envio a provedores externos.
- Usar dados ficticios ou publicos nos testes iniciais.

## Arquitetura sugerida

```text
Documentos autorizados -> OCR/extracao -> classificacao -> indice RAG local -> interface controlada
```

## Governanca

Cada base deve ter responsavel, finalidade, politica de exclusao e nivel de acesso.
