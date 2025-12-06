#!/bin/sh
#Stop if anything fails in this script:
set -e
set -x #Usefull for debugging (prints cmds with a + before it)

#1)WordPress directory preparation
mkdir -p /var/www/wordpress
cd /var/www/wordpress

#2)Install WP-CLI
if [ ! -f /usr/local/bin/wp ]; then
    # This code only runs if /usr/local/bin/wp does NOT exist, hence the if fi statement.
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

#3)Wait for MariaDB
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h mariadb --silent; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done
echo "MariaDB is up and ready!"

#4)Download WordPress
if [ ! -f wp-config.php ]; then
	echo "Downloading WordPress..."
	wp core download --allow-root

	#5)Create wp-config.php
	echo "Creating wp-config.php"
	wp config create \
		--dbname=${SQL_DATABASE} \
		--dbuser=${SQL_USER} \
		--dbpass=${SQL_PASSWORD} \
		--dbhost=mariadb \
		--allow-root

	#6)Install WordPress
	echo "Installing WordPress..."
	wp core install \
		--url=${DOMAIN_NAME} \
		--title="Inception WordPress" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--allow-root #Bypass restrictions from WP-CLI that prevents commands to run as the root user.(Docker containers often run as root by default.)

	#7)Creating another user
	echo "Creating additional WordPress user..."
	wp user create ${WP_USER} ${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD} \
		--allow-root
fi

#7)Start PHP-FPM (for debian:bookworm fpm8.2 is the version available)
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F