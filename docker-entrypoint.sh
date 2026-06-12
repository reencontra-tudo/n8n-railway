#!/bin/sh
set -e

# Corrigir permissões do volume montado em /data
# Rodando como root, então temos permissão para fazer isso
mkdir -p /data
chown -R node:node /data
chmod -R 755 /data

# Iniciar o n8n como usuário node usando gosu
exec gosu node n8n start
