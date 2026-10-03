#!/usr/bin/env bash
# Cria/atualiza todas as tabelas e carrega as regras iniciais. Pode rodar mais de uma vez.
set -euo pipefail
cd "$(dirname "$0")"; source ./config.sh
echo ">> Estrutura do banco..."; psql_db -q < 01_banco.sql
echo ">> Regras iniciais (todas NÃO validadas)..."; psql_db -q < 02_regras_iniciais.sql
echo ">> Limpando linhas de teste antigas sem nota vinculada..."
psql_db -q -c "DELETE FROM auditoria_quarentena WHERE nfe_id IS NULL;"
echo "OK. Próximo passo: ./cliente_novo.sh CNPJ \"Nome\" REGIME ATIVIDADE"
