#!/bin/sh

#wp-init.sh

# Wait until mariadb is running
echo "wp-init.sh: Waiting for database..."
while ! mysqladmin ping -h ${DB_HOST}; do
    sleep 1
done

# Check if wordpress is installed
echo "wp-init.sh: moving to wordpress path"
cd /var/www/html
echo "wp-init.sh: checking wordpress installation..."
if ! wp core is-installed --allow-root; then
	echo "wp-init.sh: wordpress is not installed, intalling it now..."
	wp core download --allow-root
	
	echo "wp-init.sh: creating the configuration file"
	wp config create --allow-root \
		--dbname="${DB_NAME}" \
    	--dbuser="${DB_USER}" \
    	--dbpass="${DB_PASS}" \
    	--dbhost="${DB_HOST}"

	echo "wp-init.sh: installing wp cli"
	wp core install --allow-root \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
    	--admin_user="${WP_ADMIN_USER}" \
    	--admin_password="${WP_ADMIN_PASS}" \
    	--admin_email="${WP_ADMIN_EMAIL}"

	echo "wp-init.sh: creating a secondary user"
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
	    --allow-root --path=/var/www/html \
	    --role=author \
	    --user_pass="${WP_USER_PASS}"	
fi

exec php-fpm8.2 -F
