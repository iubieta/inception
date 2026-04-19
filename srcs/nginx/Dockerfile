# dockerfile nginx
FROM debian:latest

RUN apt update
RUN apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring 
RUN apt install -y nginx

CMD ["nginx", "-g", "daemon off;"]
