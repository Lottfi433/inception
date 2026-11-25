#!/bin/sh

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: database password is empty" >&2
    exit 1
fi
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi
if [ ! -f /var/lib/mysql/.wordpress_initialized ]; then

    mariadbd --user=mysql --skip-networking &
    MYSQL_PID=$!

    until mariadb-admin ping --silent; do
        if ! kill -0 "$MYSQL_PID" 2>/dev/null; then
            echo "Error: MariaDB failed to start" >&2
            exit 1
        fi
        sleep 1
    done

    echo "MariaDB is ready!"

    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

    ESCAPED_PASSWORD=$(printf '%s' "$MYSQL_PASSWORD" | sed "s/\\\\/\\\\\\\\/g; s/'/''/g")

    printf "CREATE USER IF NOT EXISTS '%s'@'%%' IDENTIFIED BY '%s';\n" "$MYSQL_USER" "$ESCAPED_PASSWORD" | mariadb -u root

    mariadb -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

    touch /var/lib/mysql/.wordpress_initialized

    mariadb-admin -u root shutdown
    wait "$MYSQL_PID"
fi
exec mariadbd --user=mysql