#!/usr/bin/env bash
# Sobe o Metabase (painel para ver e exportar os achados) em http://localhost:3000
set -euo pipefail
docker volume create metabase_data >/dev/null
docker run -d --name metabase -p 3000:3000 --add-host=host.docker.internal:host-gateway \
  -v metabase_data:/metabase-data -e MB_DB_FILE=/metabase-data/metabase.db metabase/metabase
echo "Abra http://localhost:3000 (leva ~1 min na primeira vez)."
echo "Ao adicionar o banco: PostgreSQL | host: host.docker.internal | porta 5432 | banco: tax_automation_db | usuário: admin"
