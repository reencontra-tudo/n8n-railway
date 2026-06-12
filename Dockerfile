FROM n8nio/n8n:latest

USER root

# Instalar gosu para trocar de usuário em runtime
RUN apk add --no-cache gosu

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5678

ENTRYPOINT ["/docker-entrypoint.sh"]
