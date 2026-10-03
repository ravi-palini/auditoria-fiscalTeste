#!/usr/bin/env bash
# Gera um CSV com os achados de um cliente (sem notas de homologação, sem itens conformes).
# Uso: ./relatorio.sh 12345678000190 > relatorio_cliente.csv   (opcional 2º argumento: só_aprovados)
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
CNPJ="${1//[^0-9]/}"; [[ ${#CNPJ} -eq 14 ]] || { echo "Uso: ./relatorio.sh CNPJ [so_aprovados]" >&2; exit 1; }
FILTRO="TRUE"; [[ "${2:-}" == "so_aprovados" ]] && FILTRO="status_revisao = 'APROVADO'"
psql_db -q -c "COPY (
  SELECT cliente, nota, data_emissao, prescricao_estimada, item_numero, produto, ncm, achado, valor_estimado,
         alerta, base_legal, status_revisao, revisado_por, observacao_revisao
  FROM v_achados
  WHERE cliente_cnpj = '$CNPJ' AND NOT homologacao
    AND achado NOT IN ('CONFORME','SEM_REGRA','FORA_ESCOPO') AND $FILTRO
  ORDER BY valor_estimado DESC NULLS LAST, data_emissao
) TO STDOUT WITH (FORMAT csv, HEADER true)"
