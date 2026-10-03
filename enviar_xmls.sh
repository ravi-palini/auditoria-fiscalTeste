#!/usr/bin/env bash
# Envia todos os XMLs de uma pasta para o n8n (workflow precisa estar ATIVO).
# Uso: ./enviar_xmls.sh ./xmls_do_cliente        (modo teste: ./enviar_xmls.sh ./pasta --teste)
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
PASTA="${1:?Uso: ./enviar_xmls.sh PASTA [--teste]}"
URL="$N8N_URL/webhook/receber-xml"; [[ "${2:-}" == "--teste" ]] && URL="$N8N_URL/webhook-test/receber-xml"
ok=0; falha=0; LOG="envio_$(date +%Y%m%d_%H%M%S).log"
shopt -s nullglob nocaseglob
for f in "$PASTA"/*.xml; do
  : > /tmp/resp_envio.json
  code=$(curl -s -o /tmp/resp_envio.json -w "%{http_code}" -X POST "$URL" -H "Content-Type: application/xml" --data-binary @"$f" 2>/dev/null) || code=000
  if [[ "$code" == "200" ]]; then ok=$((ok+1)); echo "OK     $f" | tee -a "$LOG"
  else falha=$((falha+1)); echo "FALHA($code) $f :: $(head -c 300 /tmp/resp_envio.json 2>/dev/null)" | tee -a "$LOG"; fi
done
echo "Enviados: $ok ok, $falha com falha. Log: $LOG"
