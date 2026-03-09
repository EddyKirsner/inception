#!/bin/sh
set -eu

mkdir -p /run/php

# Download wordPress if volume is empty
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[WP] Downloading WordPress..."

    rm -rf /var/www/html/*

    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp

    mv /tmp/wordpress/* /var/www/html/

    rm -rf /tmp/wordpress
    rm -f /tmp/wp.tar.gz
fi

chown -R www-data:www-data /var/www/html
mkdir -p /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www/html/wp-content

MYSQL_PASSWORD="$(tr -d '\r\n' < "$MYSQL_PASSWORD_FILE")"
WP_ADMIN_PASSWORD="$(tr -d '\r\n' < "$WP_ADMIN_PASSWORD_FILE")"
WP_USER_PASSWORD="$(tr -d '\r\n' < "$WP_USER_PASSWORD_FILE")"

# echo "$MYSQL_PASSWORD"
# echo "$MYSQL_USER"
# echo "$MYSQL_DATABASE"

echo "Waiting mariadb..."

while ! mysqladmin ping \
    -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    --silent
do
    sleep 1
done

echo "mariadb ready"

# Create wp-config.php
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --skip-check
fi

# Install wordPress
if ! wp core is-installed --allow-root --path=/var/www/html; then
    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"

    wp user create \
        --allow-root \
        --path=/var/www/html \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" || true
fi

exec php-fpm8.2 -F