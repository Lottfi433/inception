#!/bin/sh

set -e
mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -days 365 \
    -subj "/CN=${DOMAIN_NAME}"

chmod 600 /etc/nginx/ssl/nginx.key

exec nginx -g "daemon off;"