#!/bin/sh
# Start mariadb temporarily to secure it
echo "init.sh: Starting temporary mariadb instance..."
mysqld --user=mysql &

# Wait until it is up
echo "init.sh: Waiting for it..."
while ! mysqladmin ping ; do
    sleep 1
done

echo "init.sh: Temporary mariadb instance STARTED"

# Check if it is secured and if not secure it 
echo "init.sh: Checking securization..."
if mariadb -u root ; then
	echo "init.sh: Server not secured. Starting securization..."
    mariadb -u root << EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
EOF
fi
echo "init.sh: Server is SECURED"

# Create the db and user
echo "init.sh: Creating database..."
mariadb -u root -p"${DB_ROOT_PASS}" << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
echo "init.sh: Database created"

# Stop temporal instance and start the definitive one
echo "init.sh: Shutting down mariadb temporary instance..."
mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
echo "init.sh: Starting definitive instance..."
exec mysqld --user=mysql
