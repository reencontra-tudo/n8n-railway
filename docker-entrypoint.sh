#!/bin/sh
set -e

# Corrigir permissões do volume montado em /home/node/.n8n
# Rodando como root, então temos permissão para fazer isso
mkdir -p /home/node/.n8n
chown -R node:node /home/node/.n8n
chmod -R 755 /home/node/.n8n

# Iniciar o n8n como usuário node usando gosu
exec gosu node n8n start
