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
>   - `mysqld` -> runs MariaDB
>   - `mysqld_safe` -> runs MariaDB and monitors it. If MariaDB crashes 
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

> [!WARNING]
> This script is interactive so using it in docker doesn't make sense
> but you can replicate it with a bash script that connects to the server
> and executes some SQL sentences with some environment variables 

## Creating a MariaDB docker container

### Dockerfile

In the container Dockerfile we will add the basic installation commands with 
the `-y` flag to automate the procces.

After that we will use an `init.sh` script as entrypoint to make the needed 
configurations and execute the mariadb server. For that we need to copy it 
and give permissions.

```Dockerfile
# dockerfile mariadb
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \

COPY init.sh /usr/local/bin
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

ENTRYPOINT ["init.sh"]
```

### init.sh script

1- First we will start a temporary mariadb instance with `mysqld` to check the 
securarization. As docker containers run with root user and mariadb doesnt allow
root initialization we must start it with `mysql` user and in order to follow
with the script we will execute it in background with `&` 
```
mysqld --user=mysql &
```

> [!NOTE]
> In a normal installation post installation scripts create folders needed for 
> mariadb to run correctly as `/run/mysqld`. When installing it in docker this 
> doesn't happen so we need to create them manually

2- After that we will wait until we are sure it has been started correctly.
We can check that with the `mysqladmin ping` command in loop:
```
while ! mysqladmin ping ; do
    sleep 1
done
```
3- Once we know it is running we can try to connect to it with root user 
and no password. If we can, that means the server is not secured so we must 
run the queries to make it secure:
```
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
```
4- After that we can shut down the temporary instance and start a definitive one 
in order to apply configuration changes
```
mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
exec mysqld --user=mysql
```

#### Here is the whole script - init.sh
```bash
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

# Stop temporal instance and start the definitive one
echo "init.sh: Shutting down mariadb temporary instance..."
mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
echo "init.sh: Starting definitive instance..."
exec mysqld --user=mysql
```

You can define the `DB_ROOT_PASS` in a .env file

## Verification
You can verify the installation by connecting as root:Bash
```
mariadb -u root -p"password"
```
Enter the root password you set during the secure installation.

> [!NOTE]
> To connect to a docker container we can use `docker exec`
> ```
> docker exec container-name mariadb -u root -p"PASSWORD"
> ```

Once connecter there are 3 points to check:
1- There is no "test" database.
```
SHOW DATABASES;
```
2- There is no anonimous users and root is only in localhost:
```
SELECT User, Host FROM mysql.user;
```
3- Root has a password and you cant connect without it:
```
mariadb -u root
# should fail
```

## Creating a Database

MariaDB wouldnt make sense without a useful database so we will create one 
and a user for it. 

To automate that in docker we can add it to the `init.sh` script after the securization
```
mariadb -u root -p"${DB_ROOT_PASS}" << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
```

## Sources
- [MariaDB installation guide ](https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide)
- [mariadbd options ](https://mariadb.com/docs/server/server-management/starting-and-stopping-mariadb/mariadbd-options)
- [mariadbd-safe ](https://mariadb.com/docs/server/server-management/starting-and-stopping-mariadb/mariadbd-safe)
- [MariaDB official docker image ](https://hub.docker.com/_/mariadb)

