# Open WebUI local

## Finalidade

Preparar uma interface web local estilo ChatGPT para uso futuro por colegas, conectada ao Ollama do Windows.

## Como iniciar

```powershell
cd C:\openclaw-douglas
powershell.exe -ExecutionPolicy Bypass -File .\tools\open-webui-local\iniciar_open_webui.ps1
```

URL local:

```text
http://localhost:3000
```

## Como parar

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\open-webui-local\parar_open_webui.ps1
```

## Status

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\open-webui-local\status_open_webui.ps1
```

## Uso interno

- Comecar por uso administrativo.
- Criar usuarios de forma controlada na propria interface.
- Separar perfis por finalidade.
- Nao usar dados investigativos sensiveis na fase inicial.

## Memoria

O modelo nao aprende sozinho. Historico de conversa, RAG e banco da interface podem funcionar como memoria operacional, mas nao alteram os pesos do modelo.

## Cuidados

- Nao expor para internet.
- Nao liberar LAN sem politica e controle.
- Nao inserir senhas, tokens ou dados sigilosos.
- Revisar respostas antes de uso oficial.
