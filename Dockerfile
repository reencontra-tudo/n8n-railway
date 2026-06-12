FROM n8nio/n8n:latest

ENV N8N_SECURE_COOKIE=false
ENV N8N_SAMESITE_COOKIE=lax
ENV N8N_EDITOR_BASE_URL=https://n8n-production-b99a.up.railway.app
ENV WEBHOOK_URL=https://n8n-production-b99a.up.railway.app
ENV N8N_PROTOCOL=https
ENV N8N_HOST=n8n-production-b99a.up.railway.app
ENV GENERIC_TIMEZONE=America/Sao_Paulo
ENV TZ=America/Sao_Paulo
ENV PORT=5678
