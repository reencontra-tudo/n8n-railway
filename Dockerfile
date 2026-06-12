FROM n8nio/n8n:latest

# Rodar como root para ter permissão de escrita no volume montado pelo Railway
# (o Railway monta volumes como root, e o chown no entrypoint é sobrescrito)
USER root
