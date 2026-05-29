# Corrigir alias Python da Microsoft Store

Em algumas instalacoes do Windows, os comandos `python.exe` e `python3.exe` podem apontar para aliases da Microsoft Store em vez de apontar para uma instalacao real do Python.

Sintomas comuns:

- `python --version` abre a Microsoft Store.
- `python --version` nao mostra a versao esperada.
- `py --version` funciona, mas `python --version` nao.
- Scripts encontram um Python diferente do esperado.

## Como desativar os aliases

1. Abra **Configuracoes** do Windows.
2. Va em **Aplicativos**.
3. Abra **Configuracoes avancadas de aplicativos**.
4. Entre em **Aliases de execucao de aplicativo**.
5. Desative:
   - `python.exe`
   - `python3.exe`

## Como testar

Feche e abra novamente o terminal.

Execute:

```powershell
python --version
py --version
where.exe python
where.exe py
```

Resultado esperado:

- `python --version` deve mostrar uma versao real instalada.
- `py --version` deve mostrar o launcher Python, se instalado.
- `where.exe python` nao deve apontar apenas para `WindowsApps` quando o objetivo for usar Python local de desenvolvimento.

Nao altere PATH manualmente sem necessidade. Prefira instaladores oficiais ou `winget` quando autorizado.
