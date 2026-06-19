# dockerfile mariadb
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/* && \
	mkdir /run/mysqld && chown mysql:mysql /run/mysqld

COPY tools/db-init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

COPY conf/99-my-config.cnf /etc/mysql/mariadb.conf.d/

EXPOSE 3306

ENTRYPOINT ["init.sh"]
