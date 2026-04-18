# Inception

[Subject](/docs/inception-en.subject.pdf)

## Project rules and objectives

### Main objective:
Build a little infrastructure with different services using docker

### Rules:
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

### Infrastructure
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

### File structure
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

## Virtual Machine setup
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

## Docker setup

### Installation

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

### Post-installation
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

## NGINX Setup

NGINX ("engine x") is an HTTP web server, reverse proxy, content cache, load 
balancer, TCP/UDP proxy server, and mail proxy server.

Full guide [here](/docs/nginx-guide.md)

### Installation

```
sudo apt update
sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
sudo apt install nginx
```


## Resources
- [Oracle VirtualBox](https://www.virtualbox.org/)
- [Oracle VirtualBox - User guide](https://www.virtualbox.org/manual/)
- [Debian 13.4 Image](https://www.debian.org/releases/trixie/debian-installer/)
- [Docker installation guide](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [NGINX - Beginner's guide](https://nginx.org/en/docs/beginners_guide.html)

