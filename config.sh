# Configuração comum dos scripts. Ajuste só se mudar os nomes no seu Docker.
CONTAINER="${CONTAINER:-postgres_core}"
DB="${DB:-tax_automation_db}"
DBUSER="${DBUSER:-admin}"
N8N_URL="${N8N_URL:-http://localhost:5678}"
psql_db() { docker exec -i "$CONTAINER" psql -U "$DBUSER" -d "$DB" -v ON_ERROR_STOP=1 "$@"; }
