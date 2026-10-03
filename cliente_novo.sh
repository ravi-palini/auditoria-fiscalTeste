#!/usr/bin/env bash
# Uso: ./cliente_novo.sh 12345678000190 "Mercado do João" SIMPLES COMERCIO
#   REGIME:    SIMPLES | PRESUMIDO | REAL
#   ATIVIDADE: COMERCIO | INDUSTRIA | IMPORTADOR   (padrão: COMERCIO)
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
CNPJ="${1:-}"; NOME="${2:-}"; REGIME="${3:-}"; ATIV="${4:-COMERCIO}"
CNPJ="${CNPJ//[^0-9]/}"
[[ ${#CNPJ} -eq 14 ]] || { echo "CNPJ precisa ter 14 dígitos."; exit 1; }
[[ -n "$NOME" ]] || { echo "Falta o nome do cliente."; exit 1; }
[[ "$REGIME" =~ ^(SIMPLES|PRESUMIDO|REAL)$ ]] || { echo "Regime deve ser SIMPLES, PRESUMIDO ou REAL."; exit 1; }
[[ "$ATIV" =~ ^(COMERCIO|INDUSTRIA|IMPORTADOR)$ ]] || { echo "Atividade deve ser COMERCIO, INDUSTRIA ou IMPORTADOR."; exit 1; }
psql_db -q -v cnpj="$CNPJ" -v nome="$NOME" -v regime="$REGIME" -v ativ="$ATIV" <<'SQL'
INSERT INTO cliente (cnpj, nome, regime, atividade) VALUES (:'cnpj', :'nome', :'regime', :'ativ')
ON CONFLICT (cnpj) DO UPDATE SET nome = EXCLUDED.nome, regime = EXCLUDED.regime, atividade = EXCLUDED.atividade;
SELECT cnpj, nome, regime, atividade FROM cliente ORDER BY criado_em DESC LIMIT 5;
SQL
