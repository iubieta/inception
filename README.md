_This project has been created as part of the 42 curriculum by iubieta-_

# Inception

## Index:
1. [Description](#intro)
    1. [Main objective](#objective)
    2. [Rules](#rules)
    3. [Infrastructure](#infra)
    4. [File structure](#files)
2. [Instructions](#instructions)
    1. [Virtual Machine setup](#vm)
    2. [Docker setup](#docker)
        1. [Installation](#docker_install)
        2. [Post-installation](#docker_post_install)
    3. [Secrets & environment variables](#secrets)
    4. [Verifying the setup](#verify)
3. [Comparisons](#comparisons)
    1. [VM vs Docker](#vm_vs_docker)
    2. [Secrets vs Env vars](#secrets_vs_env)
    3. [Docker network vs Host network](#network_vs_host)
    4. [Volumes vs Bind mounts](#volumes_vs_bind)
4. [Resources](#res)

## Description <a name="intro"></a>

- [Subject](/docs/inception-en.subject.pdf)

### Main objective: <a name="objective"></a>
Build a little infrastructure with 3 different services (nginx, mariadb and
wordpress) using docker.

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
├── docs/
│   ├── env-and-secrets.md
│   ├── docker-guide.md
│   ├── nginx-guide.md
│   ├── mariadb-guide.md
│   └── wordpress-guide.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   ├── site.crt
│   └── site.key
└── srcs/
    ├── compose.yml
    ├── .env
    ├── .env.example
    ├── mariadb/
    │   ├── conf/
    │   ├── Dockerfile
    │   └── tools/
    ├── nginx/
    │   ├── conf/
    │   ├── Dockerfile
    │   └── tools/
    └── wordpress/
        ├── Dockerfile
        └── tools/

```

## Instructions <a name="instructions"></a>
### Virtual Machine setup <a name="vm"></a>
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

### Docker setup <a name="docker"></a>

#### Installation <a name="docker_install"></a>

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

#### Post-installation <a name="docker_post_install"></a>
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

### Secrets & environment variables <a name="secrets"></a>

The services need some delicate info as well as defined users and passwords.
This configuration is split in two places. Info that is not confidential,
such as the DB name or usernames, is defined in a `.env` file as environment
variables that are later read by the containers. Confidential info, such as
passwords or the TLS certificate/key, is handled as Docker secrets, mounted
at runtime under `/run/secrets/<name>` inside each container and never
exposed as an environment variable.

Full reference of every variable and secret needed, plus the commands to
regenerate `secrets/` from scratch on a new machine, is in
[env-and-secrets.md](/docs/env-and-secrets.md).

Before building, make sure `srcs/.env` (copy it from `srcs/.env.example`) and
the 6 files under `secrets/` exist — `make check-env` will refuse to build
otherwise.

#### Server name or domain setup
To change the domain or server name you must define the ip related to that
domain on the `/etc/hosts` file of the machine from which you are trying to
make the connection to the server.
```
#/etc/hosts
127.0.0.1   localhost
127.0.0.1   server-name
```

### Verifying the setup <a name="verify"></a>

Once `make` (or `make up`) finishes, use this checklist to confirm everything
is actually working, not just that the build didn't error out:

1. **Containers up and stable**
    ```
    make ps
    ```
    All three (`nginx`, `mariadb`, `wordpress`) should be `Up`/`running`.

2. **No errors in the logs**
    ```
    make logs
    ```

3. **Volumes actually populated**
    ```
    ls /home/user/data/wordpress   # wp-config.php, wp-content, etc.
    ls /home/user/data/mariadb     # ibdata1, etc.
    ```

4. **HTTPS access works**
    ```
    curl -vk https://server-name
    ```
    (`-k` because the certificate is self-signed). Should return WordPress'
    HTML.

5. **Only TLS 1.2/1.3 are accepted**
    ```
    openssl s_client -connect server-name:443 -tls1_1
    ```
    This must fail. With `-tls1_2` it must connect.

6. **NGINX is the only reachable entrypoint**
    ```
    curl http://localhost:3306   # must fail / connection refused
    curl http://localhost:9000   # must fail / connection refused
    ```

7. **WordPress login**
    Log in at `https://server-name/wp-admin` with both the admin user and the
    second user, and confirm the second one has a restricted menu (no
    Plugins/Users/Settings).

8. **Persistence**
    ```
    make down
    make up
    ```
    Confirm WordPress still has your data (it isn't reinstalled from scratch).

## Comparisons <a name="comparisons"></a>

### VM vs Docker <a name="vm_vs_docker"></a>
A Virtual Machine virtualizes a whole PC inside it, including the kernel, 
that means it needs to have direct access to part of the system's memory and 
storage. This is heavier and slower but gives full isolation from the host.
On the other side, Docker containers only isolates the process, filesystem 
and network layers making them much lighter, faster and easy to reproduce.
In this project we use the VM to isolate the host from the evaluator's machine 
and Docker to build the different services and isolate them from each other.

### Secrets vs Env vars <a name="secrets_vs_env"></a>
Environment variables (`.env` / `env_file`) are stored as plain text and visible 
from the inside and outside of the container; that is why they are not meant to 
be used for confidential information such as passwords or keys/certificates.
For that purpose Docker Secrets should be used. These are files mounted only at 
runtime inside the container as `/run/secrets/<name>`, they are not exposed nor 
written in the container image. Taking this into account is why in this project 
there are some public configs such as hostnames or usernames defined as environment
variables but others such as the passwords and TLS private key as secrets.
For a better understanding of the project setup on this aspect see 
[env-and-secrets.md](/docs/env-and-secrets.md)

### Docker network vs Host network <a name="network_vs_host"></a>
`network_mode: host` makes a container share the host's network directly, 
with no isolation and no need for port mapping. However this also means
any service running that way is as exposed as the host itself, which is why
the subject forbids it. This project instead declares an explicit
user-defined bridge network (`inception`) and attaches the three services to
it: each container gets its own private IP, an embedded DNS server lets them
resolve each other by service name (`mariadb`, `wordpress`), and only the
ports explicitly published in `compose.yml` (443, on nginx) are reachable
from outside; mariadb and wordpress are reachable only from other
containers on that same network.

There are other docker network possible configurations however they add too 
much complexity for this case. You can read about Docker networks here: 
[Docker Networking](https://docs.docker.com/engine/network/#drivers)

### Volumes vs Bind mounts <a name="volumes_vs_bind"></a>
Bind mounts link a host path directly to the container. They are fast and easy 
to set up; however, they depend on the host completely, docker doesn't handle the 
host's path, it's permissions or the existence itself. This is why the subject
forbids using them and asks for Docker volumes instead. 
Docker volumes are first-class objects they don't depend on the host nor any 
specific container. However, the subject asks for the data to live in a certain 
path and volumes automatically store it in `/var/lib/docker/volumes/...`; that's
why we must configure the volume the next way:
```yaml
name:
  driver: local
  driver_opts:
    type: none
    o: bind
    device: /home/user/data/name

```
Whith this we mount the volume with the bind option forcing the data to live 
in the specified path.


## Resources <a name="res"></a>
- [Oracle VirtualBox](https://www.virtualbox.org/)
- [Oracle VirtualBox - User guide](https://www.virtualbox.org/manual/)
- [Debian 13.4 Image](https://www.debian.org/releases/trixie/debian-installer/)
- [Docker installation guide](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Docker basics](https://docs.docker.com/get-started/)
- [Docker engine manuals](https://docs.docker.com/engine/)
- [NGINX - Beginner's guide](https://nginx.org/en/docs/beginners_guide.html)
- [TLS - Transport Layer Security](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Transport_Layer_Security)
- [NGINX - HTTPS server config](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [Docker - basic user guide](/docs/docker-guide.md)
- [NGINX - basic user guide](/docs/nginx-guide.md)
- [MariaDB - basic user guide](/docs/mariadb-guide.md)
- [Wordpress - basic user guide](/docs/wordpress-guide.md)
