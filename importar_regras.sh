#!/usr/bin/env bash
# Carrega regras em massa a partir de um CSV (veja modelo_regras.csv). Atualiza as que já existem.
# Uso: ./importar_regras.sh regras.csv
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
ARQ="${1:?Uso: ./importar_regras.sh regras.csv}"
docker cp "$ARQ" "$CONTAINER":/tmp/regras_import.csv
psql_db <<'SQL'
BEGIN;
CREATE TEMP TABLE stg (ncm_prefixo text, tributo text, tratamento text, regime text, aliquota_esperada text,
  cst_esperados text, base_legal text, vigencia_inicio text, vigencia_fim text, validada text, descricao text);
\copy stg FROM '/tmp/regras_import.csv' WITH (FORMAT csv, HEADER true)
INSERT INTO regra_fiscal (ncm_prefixo, tributo, tratamento, regime, aliquota_esperada, cst_esperados, base_legal, vigencia_inicio, vigencia_fim, validada, descricao)
SELECT trim(ncm_prefixo), COALESCE(NULLIF(trim(tributo),''),'PIS_COFINS'), NULLIF(trim(tratamento),''),
       COALESCE(NULLIF(trim(regime),''),'TODOS'), NULLIF(aliquota_esperada,'')::numeric, NULLIF(trim(cst_esperados),''),
       base_legal, vigencia_inicio::date, NULLIF(vigencia_fim,'')::date,
       COALESCE(lower(trim(validada)) IN ('true','t','1','sim','s'), false), descricao
FROM stg
ON CONFLICT (ncm_prefixo, tributo, regime, vigencia_inicio) DO UPDATE SET
  tratamento = EXCLUDED.tratamento, aliquota_esperada = EXCLUDED.aliquota_esperada, cst_esperados = EXCLUDED.cst_esperados,
  base_legal = EXCLUDED.base_legal, vigencia_fim = EXCLUDED.vigencia_fim, validada = EXCLUDED.validada, descricao = EXCLUDED.descricao;
SELECT count(*) AS regras_no_banco, count(*) FILTER (WHERE validada) AS validadas FROM regra_fiscal;
COMMIT;
SQL
