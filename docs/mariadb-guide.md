# MariaDB - Starting guide

## What is MariaDB?
MariaDB is a community-developed, commercially supported fork of the MySQL 
relational database management system (RDBMS), intended to remain free and 
open-source software under the GNU General Public License.

Database management system (DBMS) is a "software system that enables users 
to define, create, maintain and control access to the database".
RDBMS is an extension of that initialism that is sometimes used when the 
underlying database is relational. 

## Installation
Update the package manager and install mariadb server and client
```
sudo apt update
sudo apt install mariadb-server mariadb-client
```

Once installed mariadb starts running as a service of systemd.
You can check its status or start it with the following commands:
- Check status
```
systemctl status mariadb
```
- Start 
```
systemctl start mariadb
```

> [!NOTE]
> In docker there's no systemd so you need to run MariaDB manually.
> You can do this with `mysqld` or `mysqld_safe`
> - `mysqld` -> runs MariaDB
> - `mysqld_safe` -> runs MariaDB and monitors it. If MariaDB crashes 
>   it will restart it automatically

## Configuration
Once mariadb is installed it is recommendable to secure the server 
doing the following:
- Create a root password
- Remove anonymous users
- Disable remote root login

You can do this running the security script
```
sudo mariadb-secure-installation
```
### Securing an installation on a non-interactive docker container
This script is interactive so using it in docker doesn't make sense
but you can replicate it with a bash script that connects to the server
and executes some SQL sentences with some environment variables 

#### secure-installtion.sh
```bash
#!/bin/sh
# Start mariadb temporarily to secure it
mysql

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
mysqladmin -u root -p ${DB_ROOT_PASS} shutdown
exec mysqld
```

You can define the `DB_ROOT_PASS` in a .env file

## Verification
You can verify the installation by connecting as root:Bash
```
mariadb -u root -p
```
Enter the root password you set during the secure installation.

## Sources
- [MariaDB installation guide ](https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide)

