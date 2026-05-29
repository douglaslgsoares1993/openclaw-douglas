#!/usr/bin/env bash
set -euo pipefail

# Preparacao assistida do Ubuntu/WSL2 para desenvolvimento.
# Instala apenas ferramentas de desenvolvimento locais; nao mexe em Render, tokens, Ollama Windows ou modelos.

log() {
  printf '[setup-wsl] %s\n' "$*"
}

confirm() {
  local question="$1"
  read -r -p "$question (s/N) " answer
  case "${answer,,}" in
    s|sim|y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

log "Inicio do setup WSL Ubuntu"

if confirm "Executar apt update/upgrade?"; then
  sudo apt update
  sudo apt upgrade -y
else
  log "apt update/upgrade ignorado pelo usuario"
fi

if confirm "Instalar pacotes base: git curl wget unzip build-essential jq ripgrep fd-find python3 pip venv?"; then
  sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    jq \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    python3-venv

  # Debian/Ubuntu empacota fd como fdfind. Criamos alias local seguro se ainda nao existir.
  mkdir -p "$HOME/.local/bin"
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
else
  log "Pacotes base ignorados pelo usuario"
fi

if confirm "Instalar uv no usuario atual?"; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  log "uv ignorado pelo usuario"
fi

if confirm "Instalar nvm e Node.js LTS?"; then
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
else
  log "nvm/Node LTS ignorado pelo usuario"
fi

if confirm "Instalar pnpm e yarn via npm global?"; then
  if command -v npm >/dev/null 2>&1; then
    npm install -g pnpm yarn
  else
    log "npm nao encontrado; pnpm/yarn nao instalados"
  fi
else
  log "pnpm/yarn ignorados pelo usuario"
fi

log "Testando ferramentas"
for cmd in git curl wget unzip jq rg fd python3 pip3 node npm pnpm yarn uv; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-10s OK ' "$cmd"
    "$cmd" --version 2>/dev/null | head -n 1 || true
  else
    printf '%-10s PENDENTE\n' "$cmd"
  fi
done

log "Setup WSL finalizado"
