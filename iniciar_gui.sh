#!/usr/bin/env bash
# Script para iniciar/parar a interface gráfica (Budibase) do sistema de auditoria fiscal
# Uso: ./iniciar_gui.sh [start|stop|restart|logs]

set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh

COMANDO="${1:-start}"

case "$COMANDO" in
  start)
    echo "Iniciando a interface gráfica (Budibase)..."
    docker compose up -d
    echo "GUI iniciada! Acesse: http://localhost:10000"
    echo "Primeiro acesso: crie o usuário administrador"
    ;;
  stop)
    echo "Parando a interface gráfica..."
    docker compose down
    echo "GUI parada."
    ;;
  restart)
    echo "Reiniciando a interface gráfica..."
    docker compose restart
    echo "GUI reiniciada."
    ;;
  logs)
    echo "Exibindo logs da GUI (Ctrl+C para sair):"
    docker compose logs -f budibase
    ;;
  *)
    echo "Uso: $0 [start|stop|restart|logs]"
    echo "  start  - Inicia a GUI"
    echo "  stop   - Para a GUI"
    echo "  restart- Reinicia a GUI"
    echo "  logs   - Mostra logs em tempo real"
    exit 1
    ;;
esac