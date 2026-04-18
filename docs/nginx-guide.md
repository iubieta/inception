# NGINX -  Basic user guide

## What is NGINX?

NGINX ("engine x") is an HTTP web server, reverse proxy, content cache, load 
balancer, TCP/UDP proxy server, and mail proxy server.

- HTTP web server = A web server stores and delivers web content to users over 
the internet
- Reverse proxy = a server (or service) that sits in front of backend servers 
(like web servers or APIs) and forwards client requests to those servers
- Content cache = software of application that runs inside a webserver. 
It stores requests and responses from the server avoiding the need to ask to
the original server that may not be near the user. This helps reducing the 
original server traffic and loading times.
- Load balancer = It distributes incoming requests across multiple servers, 
keeping your site fast, reliable, and secure
- TCP/UDP proxy server = an intermediary that handles both Transmission Control
Protocol (reliable) and User Datagram Protocol (fast/connectionless) traffic, 
acting as a bridge between clients and backend servers
- Mail proxy server = an intermediary server that sits between email clients 
(like Outlook) and mail servers, managing, filtering, and securing traffic

## Installation

### Debian

> [!NOTE]
> It is recommendable to refresh the package manager index before installing any
> package
> ```
> apt update
>```

#### Install dependencies

```
apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
```

#### Install NGINX

```
apt install nginx
```


