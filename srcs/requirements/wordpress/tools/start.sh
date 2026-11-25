#!/bin/sh

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
REDIS_PASSWORD=$(cat /run/secrets/redis_password)

if [ ! -f /var/www/html/wp-includes/version.php ]; then
    wp core download --path=/var/www/html --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbhost="$MYSQL_HOST" \
        --dbpass="$MYSQL_PASSWORD" \
        --path=/var/www/html \
        --allow-root
fi

if  ! wp core is-installed --path=/var/www/html --allow-root ; then
    wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="$WP_TITLE" \
    --admin_user="$ADMIN_USERNAME" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$ADMIN_EMAIL" \
    --skip-email \
    --path=/var/www/html \
    --allow-root
fi
if ! wp user get "$NORMAL_USER_USERNAME" --field=ID --path=/var/www/html --allow-root; then
    wp user create "$NORMAL_USER_USERNAME" "$NORMAL_USER_EMAIL" \
    --role=author \
    --user_pass="$WP_USER_PASSWORD" \
    --path=/var/www/html \
    --allow-root
fi
chown -R www-data:www-data /var/www/html
chmod 640 /var/www/html/wp-config.php
#this for redis service
wp config set WP_REDIS_HOST 'redis' --type=constant --path=/var/www/html --allow-root

wp config set WP_REDIS_PORT 6379 --raw --type=constant --path=/var/www/html --allow-root


wp config set WP_REDIS_PASSWORD \
    'rtrim(file_get_contents("/run/secrets/redis_password"), "\r\n")' \
    --raw \
    --type=constant \
    --path=/var/www/html \
    --allow-root
if ! wp plugin is-installed redis-cache --path=/var/www/html --allow-root; then
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
fi

if ! wp redis status --path=/var/www/html --allow-root 2>/dev/null | grep -q "Status: Connected"; then
    wp redis enable --path=/var/www/html --allow-root
fi
exec php-fpm8.2 -F