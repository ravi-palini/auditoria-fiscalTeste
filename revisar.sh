#!/usr/bin/env bash
# Registra a decisão humana sobre um ou mais achados.
# Uso: ./revisar.sh "12,13,14" APROVADO "Maria Contadora" "observação opcional"
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
IDS="${1:?Uso: ./revisar.sh \"1,2,3\" APROVADO|REJEITADO|AJUSTADO \"Seu nome\" [\"observação\"]}"
DEC="${2:?Falta a decisão}"; NOME="${3:?Falta o seu nome}"; OBS="${4:-}"
[[ "$DEC" =~ ^(APROVADO|REJEITADO|AJUSTADO)$ ]] || { echo "Decisão deve ser APROVADO, REJEITADO ou AJUSTADO."; exit 1; }
[[ "$IDS" =~ ^[0-9]+([[:space:]]*,[[:space:]]*[0-9]+)*$ ]] || { echo "IDs devem ser números separados por vírgula."; exit 1; }
psql_db -q -v ids="$IDS" -v dec="$DEC" -v nome="$NOME" -v obs="$OBS" <<'SQL'
UPDATE auditoria_quarentena
SET status_revisao = :'dec', revisado_por = :'nome', revisado_em = now(), observacao_revisao = NULLIF(:'obs','')
WHERE id = ANY(string_to_array(regexp_replace(:'ids','\s','','g'), ',')::int[])
RETURNING id, status_revisao, revisado_por;
SQL
