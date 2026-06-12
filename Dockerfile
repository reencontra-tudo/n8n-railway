FROM n8nio/n8n:latest

USER root

# Garantir que o diretório /data existe e tem permissões corretas para o usuário node
RUN mkdir -p /data && chown -R node:node /data && chmod -R 755 /data

USER node

EXPOSE 5678

CMD ["n8n", "start"]
