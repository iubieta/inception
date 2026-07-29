# dockerfile nginx
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends nginx && \
	rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/my_site.conf /etc/nginx/conf.d/default.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
