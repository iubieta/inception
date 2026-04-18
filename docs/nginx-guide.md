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

## Configuration

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
