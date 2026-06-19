# dockerfile nginx
FROM debian:bookworm-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends nginx && \
	rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/my_site.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
