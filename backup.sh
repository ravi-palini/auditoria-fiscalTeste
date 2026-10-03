#!/usr/bin/env bash
# Backup completo do banco em um arquivo .sql com a data. Rode antes de mexer em regras e toda semana.
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
ARQ="backup_$(date +%Y%m%d_%H%M).sql"
docker exec "$CONTAINER" pg_dump -U "$DBUSER" "$DB" > "$ARQ"
echo "Backup salvo em $ARQ"
