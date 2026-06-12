#!/bin/sh
set -e

# Corrigir permissões do volume montado em /data
# Rodando como root, então temos permissão para fazer isso
mkdir -p /data
chown -R node:node /data
chmod -R 755 /data

# Remover variável problemática que tenta ler arquivo inexistente
unset DB_SQLITE_DATABASE_FILE

# Iniciar o n8n como usuário node
exec su-exec node n8n start
