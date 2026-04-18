# Docker - Basic user guide

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

## Usage <a name="usage"></a>

### Basic commands <a name="docker_cmds"></a>

### Dockerfiles <a name="dockerfiles"></a>
