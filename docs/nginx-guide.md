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

Install dependencies
```
apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
```

Install NGINX
```
apt install nginx
```

To test nginx you can start it with the command `nginx`. 
After that you should be able to see the welcome page in `http://localhost`

> [!NOTE]
> - If you are running nginx in a docker container you mast link the port 80.
> - If you are running it on a VM make sure the port is linked and substitute
> localhost with the VM ip.

## Configuration <a name="nginx_config"></a>
The way nginx and its modules work is determined in the configuration file. 
By default, the configuration file is named `nginx.conf` and placed in the 
directory `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`. 

### Control signals (start, stop, reload ...)
To start nginx, run the executable file. Once nginx is started, it can be 
controlled by invoking the executable with the -s parameter. 
Use the following syntax:

```
nginx -s signal
```

Where signal may be one of the following:

```
stop — fast shutdown
quit — graceful shutdown
reload — reloading the configuration file
reopen — reopening the log files
```

> [!NOTE]
> This command should be executed under the same user that started nginx.

Changes made in the configuration file will not be applied until the command 
to reload configuration is sent to nginx or it is restarted. 
To reload configuration, execute:

```
nginx -s reload
```

Once the master process receives the signal to reload configuration, it checks 
the syntax validity of the new configuration file and tries to apply the 
configuration provided in it.

If it fails, the master process rolls back the changes and continues to work 
with the old configuration.

### Configuration file structure
NGINX consists of modules which are controlled by directives specified in the 
configuration file. 
Directives are divided into simple directives and block directives. 
A simple directive consists of the name and parameters separated 
by spaces and ends with a semicolon (;). 
A block directive has the same structure as a simple directive, 
but instead of the semicolon it ends with a set of additional instructions 
surrounded by braces ({ and }). 
If a block directive can have other directives inside braces, it is called a 
context (examples: events, http, server, and location).

Directives placed in the configuration file outside of any contexts are 
considered to be in the main context. 
The events and http directives reside in the main context, server in http, 
and location in server.

The rest of a line after the # sign is considered a comment.

### Serving static content
An important web server task is serving out files. 
Depending on the request, files will be served from different local directories

#### Example
```
server {
    location / {
        root /data/www;
    }

    location /images/ {
        root /data;
    }
}
```
This is a working configuration of a server that listens on the standard 
port 80 and is accessible on the local machine at http://localhost/. 

In response to requests with URIs starting with /images/, the server will send 
files from the /data/images directory. 
For example, in response to the http://localhost/images/example.png request 
nginx will send the /data/images/example.png file. 
If such file does not exist, nginx will send a response indicating the 404 error. 

Requests with URIs not starting with /images/ will be mapped onto the /data/www 
directory. 
For example, in response to the http://localhost/some/example.html request 
nginx will send the /data/www/some/example.html file.

### Setting Up a Simple Proxy Server
One of the frequent uses of nginx is setting it up as a proxy server, which 
means a server that receives requests, passes them to the proxied servers, 
retrieves responses from them, and sends them to the clients.

#### Example
```
server {
    location / {
        proxy_pass http://localhost:8080/;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```

This server will filter requests ending with .gif, .jpg, or .png and map them 
to the /data/images directory (by adding URI to the root directive’s parameter) 
and pass all other requests to the proxied server (localhost:8080). 

### Setting Up FastCGI Proxying
NGINX can be used to route requests to FastCGI servers which run applications 
built with various frameworks and programming languages such as PHP. 

The most basic nginx configuration to work with a FastCGI server includes using 
the `fastcgi_pass` directive instead of the `proxy_pass` directive, 
and `fastcgi_param` directives to set parameters passed to a FastCGI server.

#### Example
```
server {
    location / {
        fastcgi_pass  localhost:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param QUERY_STRING    $query_string;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```

This will set up a server that will route all requests except for requests for 
static images to the proxied server operating on localhost:9000 through the 
FastCGI protocol.

> [!NOTE]
> In PHP, the SCRIPT_FILENAME parameter is used for determining the script name, 
> and the QUERY_STRING parameter is used to pass request parameters.

## TLS - Making HTTP secure (HTTPS)
Transport Layer Security (TLS) is a protocol which enables a client to 
communicate securely with a server across an untrusted network. 
Most notably it's used to secure HTTP connections on the web: 
the resulting protocol is called HTTPS.
All websites should serve all their pages and subresources over HTTPS, 
and implement server authentication.

### How to configure HTTPS server
To configure an HTTPS server, the ssl parameter must be enabled on listening 
sockets in the server block, and the locations of the server certificate 
and private key files should be specified:
```
server {
    listen              443 ssl;
    server_name         www.example.com;
    ssl_certificate     www.example.com.crt;
    ssl_certificate_key www.example.com.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ...
}
```
> [!WARNING]
> The private key is a secure entity and should be stored in a file with 
> restricted access, however, it must be readable by nginx’s master process.

The directives `ssl_protocols` and `ssl_ciphers` can be used to limit connections 
to include only the strong versions and ciphers of SSL/TLS.
> [!NOTE]
> By default nginx uses “ssl_protocols TLSv1.2 TLSv1.3” and 
> “ssl_ciphers HIGH:!aNULL:!MD5”, 
> so configuring them explicitly is generally not needed.

## SSL Certificates
If you would like to use an SSL certificate to secure a service but you do not 
require a CA-signed certificate, a valid (and free) solution is to sign your 
own certificates.

A common type of certificate that you can issue yourself is a self-signed certificate. 
A self-signed certificate is a certificate that is signed with its own private key. 
Self-signed certificates can be used to encrypt data just as well as CA-signed 
certificates, but your users will be displayed a warning that says that the 
certificate is not trusted by their computer or browser. 
Therefore, self-signed certificates should only be used if you do not need to 
prove your service’s identity to its users (e.g. non-production or non-public servers).

### Generating an Self-Signed Certificate
Use this method if you want to use HTTPS (HTTP over TLS), 
and you do not require that your certificate be signed by a CA.

This command creates a 2048-bit private key (domain.key) and a 
self-signed certificate (domain.crt) from scratch:
```
openssl req \
       -newkey rsa:2048 -nodes -keyout domain.key \
       -x509 -days 365 -out domain.crt
```
Answer the CSR information prompt to complete the process.

The -x509 option tells req to create a self-signed certificate. 
The -days 365 option specifies that the certificate will be valid for 365 days.
A temporary CSR is generated to gather information to associate with the certificate.

> [!WARNING]
> Never commit or upload your private key (.key) files to version control, 
> container registries, or any public/shared location. 
> Generate your certificates locally on each machine and keep your private key secure.

## References
- [NGINX - Beginner's guide](https://nginx.org/en/docs/beginners_guide.html)
- [NGINX - HTTPS server config](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [TLS - Transport Layer Security](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Transport_Layer_Security)
- [TLS Configuration](https://developer.mozilla.org/en-US/docs/Web/Security/Practical_implementation_guides/TLS)
- [Open SSL Guide - Introduction to TLS](https://docs.openssl.org/master/man7/ossl-guide-tls-introduction/#name)
- [Creating a SSL certificate with OpenSSL](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)
