# dockerfile mariadb
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

COPY init.sh /usr/local/bin
RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["init.sh"]
