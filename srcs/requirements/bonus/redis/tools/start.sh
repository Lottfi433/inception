#!/bin/sh
set -e

REDIS_PASSWORD=$(cat /run/secrets/redis_password)

if [ -z "$REDIS_PASSWORD" ]; then
    echo "Error: Redis password is empty" >&2
    exit 1
fi

exec redis-server \
    --bind 0.0.0.0 \
    --protected-mode yes \
    --requirepass "$REDIS_PASSWORD" \
    --daemonize no
