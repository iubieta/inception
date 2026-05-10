# dockerfile nginx
FROM debian:bookworm-slim

RUN apt-get update && \
	apt install -y --no-install-recommends nginx && \
	rm -rf /var/lib/apt/lists/*

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
