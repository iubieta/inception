# dockerfile nginx
FROM debian:latest

RUN apt update
RUN apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring 
RUN apt install -y nginx

COPY ssl /etc/nginx/ssl
COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
