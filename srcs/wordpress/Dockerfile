# dockerfile wordpress
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends php \
	php-fpm php-mysql mariadb-client wget ca-certificates && \
	rm -rf /var/lib/apt/lists/*

RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	mkdir -p /var/www/html/ && \
	mv wordpress/* /var/www/html/ && \
	rm -rf latest.tar.gz wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/wp-init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

ENTRYPOINT ["init.sh"]
