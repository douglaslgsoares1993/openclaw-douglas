# Final de expediente

Checklist operacional para verificar se a estacao IA_DELEGACIA pode ficar ligada com seguranca ao fim do expediente.

## Arquivo

- `checklist_final_expediente.ps1`: testa Ollama local, URL publica, modelo `qwen2.5:14b`, GPU e discos.

## Como rodar

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\final-expediente\checklist_final_expediente.ps1 -PublicBaseUrl "https://don-pike-suggestions-reveals.trycloudflare.com"
```

## Resultado

O script gera relatorio em:

```text
logs/final-expediente/
```

E mostra:

```text
PODE SAIR COM SEGURANCA
```

ou:

```text
ATENCAO
```

## O que ele verifica

- Ollama local em `http://localhost:11434`.
- Geração com `qwen2.5:14b`.
- URL publica configuravel.
- `nvidia-smi`.
- Espaço em disco C: e D:.

## Cuidados

- Nao reiniciar a maquina sem necessidade.
- Nao fechar Ollama/tunnel se o bot depende deles.
- Nao usar dados sensiveis no prompt de teste.
