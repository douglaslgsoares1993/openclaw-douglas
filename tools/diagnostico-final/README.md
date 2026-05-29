# Diagnostico final

Gera um relatorio geral da estacao IA_DELEGACIA sem alterar sistema.

## Uso

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\diagnostico-final\diagnostico_geral_ia_delegacia.ps1 -PublicUrl "https://don-pike-suggestions-reveals.trycloudflare.com"
```

Se `-PublicUrl` nao for informado, o teste publico fica pendente, mas o diagnostico local continua.

Relatorios:

```text
logs/diagnostico-final/
```
