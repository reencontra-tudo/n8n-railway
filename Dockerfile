FROM n8nio/n8n:latest

USER root

# Instalar nginx e supervisor (Alpine Linux usa apk)
RUN apk add --no-cache nginx supervisor

# Configuração do nginx como proxy reverso que remove X-Frame-Options
RUN mkdir -p /etc/nginx/http.d && \
    cat > /etc/nginx/http.d/default.conf << 'NGINX_CONF'
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

# Remover config padrão do nginx Alpine
RUN rm -f /etc/nginx/conf.d/default.conf 2>/dev/null; \
    mkdir -p /var/log/supervisor /var/run/supervisor

# Configuração do supervisor
RUN cat > /etc/supervisord.conf << 'SUPERVISOR_CONF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisor/supervisord.pid

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
# N8N_SECURE_COOKIE=true garante que o cookie tem flag Secure (necessário para HTTPS)
# SameSite=lax é compatível com Chrome moderno sem precisar de flag Secure explícita
ENV N8N_SECURE_COOKIE=true
ENV N8N_SAMESITE_COOKIE=lax
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

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
