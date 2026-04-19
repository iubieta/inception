# Inception

## Index:
1. [Project rules and objectives](#intro)
    1. [Main objective](#objective)
    2. [Rules](#rules)
    3. [Infraestructure](#infra)
    4. [File structure](#files)
2. [Virtual Macine setup](#vm)
3. [Docker setup](#docker)
    1. [Installation](#docker_install)
    2. [Post-installation](#docker_post_install)
4. [Docker basics](#docker_basics)
    1. [Containers](#docker_containers)
    2. [Images](#docker_images)
    3. [Dockerfiles](#docker_dockerfiles)
    4. [Docker compose](#docker_compose)
5. [NGINX setup](#nginx)
    1. [Installation](#nginx_install)
    2. [Configuration](#nginx_config)
5. [Resources](#res)

## Project rules and objectives <a name="intro"></a>

- [Subject](/docs/inception-en.subject.pdf)

### Main objective: <a name="objective"></a>
Build a little infrastructure with different services using docker

### Rules: <a name="rules"></a>
- Work in a Virtual Machine
- Each service must be contained in a docker container named as the service
- Every container must be based on a clean Alpine or Debian image
- Each service must have its Dockerfile
- It is forbidden to use ready-made Docker images
- Dockerfile must be called from docker-compose.yml with Makefile
- Passwords and confidential info must be handled with docker secrets
    - It is forbidden to have passwords on the Dockerfiles
- .env must be used to handle enviroment variables
- You should only be able to acces the infraestructure through NGINX
    - NGINX must be accesible through the port 443

### Infrastructure <a name="infra"></a>
#### Containers
- NGINX (TLS 1.2 or 1.3)
- Wordpress + PHP-fpm
    - Must have 2 users. One of them being the admin 
    but it cannot be named `admin` or similar
- MariaDB
> [!WARNING]
> - Containers cannot be started with an infinite command
> - tail -f, bash, sleep inite, while true, etc. are forbidden


#### Volumes
- Wordpress DB
- Web-files for Wordpress
> [!WARNING]
> - Volumes must be called. They cant be bind-mounts
> - Volumes must be hosted in /home/user/data directory

#### Network
- Containers must be linked with a docker network
- Domain name must point to the local IP of the host and named `user.42.fr`
> [!WARNING]
> - Docker network cant be host, --link or links>

![Visual scheme](/res/inception_scheme.png)

### File structure <a name="files"></a>
```
Project Folder
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── conf
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── tools
        │   └── ...
        ├── nginx
        │   ├── conf
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── tools
        │   └── ...
        └── ...

``` 

## Virtual Machine setup <a name="vm"></a>
1. Install VirtualBox if it is not installed
2. Open a Virtual Machine based on Debian 13.4 ISO
3. Config the VM OS:
    - Keyboard layout
    - Add user to sudoers:
    ```
    su
    sudo visudo
    ```
    Once in the sudoers config file, copy the root user config line and paste 
    it with the actual user
    ```
    # User privilege specification
    root    ALL=(ALL:ALL) ALL
    iubieta ALL=(ALL:ALL) ALL
    ```
    - SSH:
    ```
    sudo apt install openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh`
    sudo systemctl status ssh`
    ```
    - In VM config, in network set the setting to NAT and add a 
        port-forwarding from HOST:3022 to VM:22
4. Connect to the VM via SSH: `ssh -p 3022 user@127.0.0.1`
5. Add any other config that you want
6. Once the VM is configured as you want it shut it down and export it from 
    the file menu in VirtualBox

## Docker setup <a name="docker"></a>

### Installation <a name="docker_install"></a>

1. Setup Docker's apt repository:
```
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

2. Install the Docker packages
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> [!NOTE]
> The Docker service starts automatically after installation.
> To verify that Docker is running, use:
> ```
> sudo systemctl status docker
> ```
> Some systems may have this behavior disabled and will require a manual start:
> ```
> sudo systemctl start docker
> ```

Verify that the installation is successful by running the hello-world image:
```
 sudo docker run hello-world
```
This command downloads a test image and runs it in a container. 
When the container runs, it prints a confirmation message and exits.

### Post-installation <a name="docker_post_install"></a>
1. Add your user to the docker group.
```
sudo usermod -aG docker $USER
```
2. Log out and log back in so that your group membership is re-evaluated.

> [!WARNING]
> If you're running Linux in a virtual machine, 
> it may be necessary to restart the virtual machine for changes to take effect.

You can also run the following command to activate the changes to groups:
```
 newgrp docker
```

3. Verify that you can run docker commands without sudo.
```
 docker run hello-world
```

## Docker basics <a name="docker_basics"></a>

### Containers <a name="docker_containers"></a> 

#### What is a Container?
Containers are isolated processes for each of your app's components. 
Each component - the frontend React app, the Python API engine, and the 
database - runs in its own isolated environment, completely isolated from 
sverything else on your machine.

#### Using containers (CLI)
- To start a container use `docker run`
    ```
    docker run -d -p 8080:80 docker/welcome-to-docker
    ```

- You can monitor active containers with `docker ps`
    ```
    docker ps
    ```
> [!TIP]
> To view stopped containers, add the -a flag to list all containers:
> ```
> docker ps -a
> ```

- You can stop a container using the `docker stop` command.
    1. Run docker ps to get the ID of the container
    2. Provide the container ID or name to the docker stop command:
        ```
        docker stop <the-container-id>
        ```
### Images <a name="docker_images"></a>

#### What is an image?
A container image is a standardized package that includes all of the files, 
binaries, libraries, and configurations to run a container.

#### Using images (CLI)
- Search for images using the `docker search` command:
    ```
    docker search docker/welcome-to-docker
    ```

- Pull the image using the docker pull command.
    ```
    docker pull docker/welcome-to-docker
    ```

- List your downloaded images using the docker image ls command:
    ```
    docker image ls
    ```

- List the image's layers using the docker image history command:
    ```
    docker image history docker/welcome-to-docker
    ```

### Dockerfiles <a name="docker_dockerfiles"></a>

#### What is a dockerfile?
A Dockerfile is a text-based document that's used to create a container image. 
It provides instructions to the image builder on the commands to run, 
files to copy, startup command, and more.

#### Common instructions
Some of the most common instructions in a Dockerfile include:
- `FROM <image>` - this specifies the base image that the build will extend.
- `WORKDIR <path>` - this instruction specifies the "working directory" or the path
in the image where files will be copied and commands will be executed.
- `COPY <host-path> <image-path>` - this instruction tells the builder to copy files
from the host and put them into the container image.
- `RUN <command>` - this instruction tells the builder to run the specified command.
- `ENV <name>` <value> - this instruction sets an environment variable that a 
running container will use.
- `EXPOSE <port-number>` - this instruction sets configuration on the image that 
indicates a port the image would like to expose.
- `USER <user-or-uid>`  - this instruction sets the default user for all subsequent 
instructions.
- `CMD ["<command>", "<arg1>"]`- this instruction sets the default command a 
container using this image will run.


### Docker Compose <a name="docker_compose"></a>

#### What is Docker Compose?
Docker compose is a tool to run and control multi-container applications.

With Docker Compose, you can define all of your containers and their 
configurations in a single YAML file. 
If you include this file in your code repository, anyone that clones your 
repository can get up and running with a single command

#### Using docker compose (CLI)
- `compose.yaml` file:
    This YAML file is where all the magic happens! It defines all the services 
    that make up your application, along with their configurations. 
    Each service specifies its image, ports, volumes, networks, and any other 
    settings necessary for its functionality

- Use the `docker compose up` command to start the application:
    ```
    docker compose up -d --build
    ```
> [!NOTE]
> - `-d` flags runs the containers in detached mode
> - `--build` force the containers image buil based on specified dockerfiles

- Use the `docker compose down` command to remove everything:
    ```
    docker compose down
    ```
    
> [!NOTE]
> **Volume persistence** 
> By default, volumes aren't automatically removed when you tear down a 
> Compose stack. 
> If you do want to remove the volumes, add the `--volumes` flag when running 
> the `docker compose down` command

## NGINX Setup <a name="nginx"></a>

NGINX ("engine x") is an HTTP web server, reverse proxy, content cache, load 
balancer, TCP/UDP proxy server, and mail proxy server.

Full guide [here](/docs/nginx-guide.md)

### Installation <a name="nginx_install"></a>

```
sudo apt update
sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
sudo apt install nginx
```

### Configuration <a name="nginx_config"></a>

#### Control signals (start, stop, reload ...)
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

Changes made in the configuration file will not be applied until the command 
to reload configuration is sent to nginx or it is restarted. 

```
nginx -s reload
```

#### Static content example
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

#### Simple Proxy Server example
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

#### FastCGI Proxying example
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

## Resources <a name="res"></a>
- [Oracle VirtualBox](https://www.virtualbox.org/)
- [Oracle VirtualBox - User guide](https://www.virtualbox.org/manual/)
- [Debian 13.4 Image](https://www.debian.org/releases/trixie/debian-installer/)
- [Docker installation guide](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [NGINX - Beginner's guide](https://nginx.org/en/docs/beginners_guide.html)

