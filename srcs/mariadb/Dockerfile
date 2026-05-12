# dockerfile mariadb
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/* && \
	mkdir /run/mysqld && chown mysql:mysql /run/mysqld

COPY init.sh /usr/local/bin
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

ENTRYPOINT ["init.sh"]
