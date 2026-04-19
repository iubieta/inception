# Docker - Basic user guide
## Index

1. [Docker setup](#docker)
    1. [Installation](#docker_install)
    2. [Post-installation](#docker_post_install)
2. [Containers](#docker_containers)
3. [Images](#docker_images)
4. [Dockerfiles](#docker_dockerfiles)
5. [Docker compose](#docker_compose)

## Setup <a name="setup"></a>

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


## Containers <a name="docker_containers"></a> 

### What is a Container?
Containers are isolated processes for each of your app's components. 
Each component - the frontend React app, the Python API engine, and the 
database - runs in its own isolated environment, completely isolated from 
sverything else on your machine.

Container are:
- Self-contained. Each container has everything it needs to function with no 
reliance on any pre-installed dependencies on the host machine.
- Isolated. Since containers run in isolation, they have minimal influence on 
the host and other containers, increasing the security of your applications.
- Independent. Each container is independently managed. Deleting one container 
won't affect any others.
- Portable. Containers can run anywhere! The container that runs on your 
development machine will work the same way in a data center or anywhere in the cloud!

### Using containers (CLI)

Container as any other Docker feature can be controlled with the docker CLI

- To start a container use `docker run`
    ```
    docker run -d -p 8080:80 docker/welcome-to-docker
    ```
    Explanation:
    - `-d` indicates detached mode
    - `-p` lets you map host ports to container ports, `host_port:container_port`. 
    In this case the host port `8080` is redirected to the container's port `80`
    - `docker/welcome-to-docker` is the base image to build the container

- You can monitor active containers with `docker ps`
    ```
    docker ps
    ```
    You will see output like the following:
    ```
     CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                      NAMES
     a1f7a4bb3a27   docker/welcome-to-docker   "/docker-entrypoint.…"   11 seconds ago   Up 11 seconds   0.0.0.0:8080->80/tcp       gracious_keldysh
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
   
> [!TIP]
> When referencing containers by ID, you don't need to provide the full ID.
> You only need to provide enough of the ID to make it unique. 

## Images <a name="docker_images"></a>

### What is an image?
A container image is a standardized package that includes all of the files, 
binaries, libraries, and configurations to run a container.

- Images are immutable. Once an image is created, it can't be modified. 
You can only make a new image or add changes on top of it.

- Container images are composed of layers. Each layer represents a set of file 
system changes that add, remove, or modify files.

### Using images (CLI)
- Search for images using the `docker search` command:
    ```
    docker search docker/welcome-to-docker
    ```
    You will see output like the following:
    ```
    NAME                       DESCRIPTION                                     STARS     OFFICIAL
    docker/welcome-to-docker   Docker image for new users getting started w…   20
    ```
    This output shows you information about relevant images available on Docker Hub.

- Pull the image using the docker pull command.
    ```
    docker pull docker/welcome-to-docker
    ```
    Each outpust's line represents a different downloaded layer of the image. 
    Remember that each layer is a set of filesystem changes and provides 
    functionality of the image.

- List your downloaded images using the docker image ls command:
    ```
    docker image ls
    ```

- List the image's layers using the docker image history command:
    ```
    docker image history docker/welcome-to-docker
    ```

## Dockerfiles <a name="docker_dockerfiles"></a>

### What is a dockerfile?
A Dockerfile is a text-based document that's used to create a container image. 
It provides instructions to the image builder on the commands to run, 
files to copy, startup command, and more.

As an example, the following Dockerfile would produce a ready-to-run Python application:
```
FROM python:3.13
WORKDIR /usr/local/app

# Install the application dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy in the source code
COPY src ./src
EXPOSE 8080

# Setup an app user so the container doesn't run as the root user
RUN useradd app
USER app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Common instructions
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

## Docker Compose <a name="docker_compose"></a>

### What is Docker Compose?
Docker compose is a tool to run and control multi-container applications.

You can use multiple docker run commands to start multiple containers.
But, you'll soon realize you'll need to manage networks, all of the flags 
needed to connect containers to those networks, and more. 
And when you're done, cleanup is a little more complicated.

With Docker Compose, you can define all of your containers and their 
configurations in a single YAML file. 
If you include this file in your code repository, anyone that clones your 
repository can get up and running with a single command

### Using docker compose (CLI)
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

    When you run this command, you should see an output like this:
    ```
    [+] Running 5/5
    ✔ app 3 layers [⣿⣿⣿]      0B/0B            Pulled          7.1s
    ✔ e6f4e57cc59e Download complete                          0.9s
    ✔ df998480d81d Download complete                          1.0s
    ✔ 31e174fedd23 Download complete                          2.5s
    ✔ 43c47a581c29 Download complete                          2.0s
    [+] Running 4/4
    ⠸ Network todo-list-app_default           Created         0.3s
    ⠸ Volume "todo-list-app_todo-mysql-data"  Created         0.3s
    ✔ Container todo-list-app-app-1           Started         0.3s
    ✔ Container todo-list-app-mysql-1         Started         0.3s
    ```

- Use the `docker compose down` command to remove everything:
    ```
    docker compose down
    ```
    You'll see output similar to the following:
    ```
    [+] Running 3/3
    ✔ Container todo-list-app-mysql-1  Removed        2.9s
    ✔ Container todo-list-app-app-1    Removed        0.1s
    ✔ Network todo-list-app_default    Removed        0.1s
    ```
    
> [!NOTE]
> **Volume persistence** 
> By default, volumes aren't automatically removed when you tear down a 
> Compose stack. 
> If you do want to remove the volumes, add the `--volumes` flag when running 
> the `docker compose down` command

