FROM n8nio/n8n:latest

# Rodar como root para ter permissão de escrita no volume montado pelo Railway
# (o Railway monta volumes como root, e o chown no entrypoint é sobrescrito)
USER root

# Configurações para funcionamento correto no Railway
ENV N8N_SECURE_COOKIE=false
ENV N8N_SAMESITE_COOKIE=none
ENV N8N_EDITOR_BASE_URL=https://n8n-production-b99a.up.railway.app
ENV WEBHOOK_URL=https://n8n-production-b99a.up.railway.app
ENV N8N_PROTOCOL=https
ENV N8N_HOST=n8n-production-b99a.up.railway.app
ENV N8N_PORT=5678
ENV GENERIC_TIMEZONE=America/Sao_Paulo
ENV TZ=America/Sao_Paulo
ENV N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true
ENV N8N_LOG_LEVEL=info

# CSP com defaultSrc e frameAncestors para permitir embed em iframe no backfindr.com
# Formato: objeto helmet.js com camelCase para as diretivas
ENV N8N_CONTENT_SECURITY_POLICY='{ "defaultSrc": ["'\''self'\''"], "frameAncestors": ["https://backfindr.com", "https://*.backfindr.com", "http://localhost:3000"] }'
