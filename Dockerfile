FROM n8nio/n8n:latest

USER root

# Instalar nginx para proxy reverso que remove X-Frame-Options
RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

# Configuração do nginx como proxy reverso
RUN cat > /etc/nginx/sites-available/default << 'NGINX_CONF'
server {
    listen 8080;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;

        # Remover headers que bloqueiam iframe
        proxy_hide_header X-Frame-Options;
        proxy_hide_header Content-Security-Policy;

        # Permitir iframe do backfindr.com
        add_header Content-Security-Policy "frame-ancestors 'self' https://backfindr.com https://*.backfindr.com http://localhost:3000 http://localhost:*" always;
    }
}
NGINX_CONF

# Configuração do supervisor para rodar n8n e nginx juntos
RUN cat > /etc/supervisor/conf.d/supervisord.conf << 'SUPERVISOR_CONF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log

[program:n8n]
command=n8n start
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/n8n.err.log
stdout_logfile=/var/log/supervisor/n8n.out.log
environment=HOME="/root",USER="root"

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
startretries=5
stderr_logfile=/var/log/supervisor/nginx.err.log
stdout_logfile=/var/log/supervisor/nginx.out.log
SUPERVISOR_CONF

# Configurações do n8n
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
# Railway usa PORT para saber qual porta expor - nginx escuta nessa porta
ENV PORT=8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
