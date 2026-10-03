#!/usr/bin/env bash
# Script para gerar uma chave de criptografia segura para o Budibase
# Uso: ./gerar_chave_secreta.sh

echo "Gerando chave de criptografia segura para o Budibase..."
echo "Copie este valor para a variável ENCRYPTION_KEY no arquivo .env:"
echo ""
openssl rand -base64 32
echo ""
echo "Importante: Guarde esta chave em local seguro!"
echo "Se perder esta chave, não será possível recuperar dados criptografados pelo Budibase."