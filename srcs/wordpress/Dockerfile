# dockerfile wordpress
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends php \
	php-fpm php-mysql wget ca-certificates && \
	rm -rf /var/lib/apt/lists/*

RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	mv wordpress/* /var/www/html/ && \
	rm -rf latest.tar.gz wordpress

EXPOSE 9000

CMD []
