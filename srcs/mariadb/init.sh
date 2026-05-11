#!/bin/sh
# Start mariadb temporarily to secure it
mysqld &

# Wait until it is up
while ! mysqladmin ping --silent 2>/dev/null; do
    sleep 1
done

# Check if it is secured and if not secure it 
if mariadb -u root --silent 2>/dev/null; then
    mariadb -u root << EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
EOF
fi

# Stop temporal instance and start the definitive one
mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
exec mysqld
