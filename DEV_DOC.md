# Developer Documentation — INCEPTION

## Prerequisites

- A Linux virtual machine (required by the subject)
- Docker Engine and Docker Compose plugin installed
- The user added to the `docker` group (`sudo usermod -aG docker $USER`)
- OpenSSL (for certificate generation)

## Setup from scratch

### 1. Clone the repository

```bash
git clone <repo-url> inception
cd inception
```

### 2. Environment file

```bash
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` with your settings:

| Variable | Example | Purpose |
|----------|---------|---------|
| `DOMAIN_NAME` | `https://iubieta-.42.fr` | WordPress site URL |
| `DB_NAME` | `wordpress` | MariaDB database name |
| `DB_USER` | `wp` | MariaDB application user |
| `WP_ADMIN_USER` | `iubieta` | WordPress admin username (no "admin" in name) |
| `WP_USER` | `random` | Second WordPress user |

### 3. Secrets

Create the `secrets/` directory and generate passwords:

```bash
mkdir -p secrets
openssl rand -hex 16 > secrets/db_password.txt
openssl rand -hex 16 > secrets/db_root_password.txt
openssl rand -hex 16 > secrets/wp_admin_password.txt
openssl rand -hex 16 > secrets/wp_user_password.txt
```

TLS certificate is generated automatically by `make`:

```bash
make certs   # or just make (it runs certs as a dependency)
```

### 4. Build and launch

```bash
make
```

This runs: `check-env` → `certs` → `prepare` → `build` → `up`

## Managing containers and volumes

```bash
make ps       # List container status
make logs     # Follow logs from all services
make stop     # Stop containers
make start    # Start containers
make down     # Stop and remove containers
make restart  # down + up
make clean    # down + docker system prune
make fclean   # clean + delete volume data from disk
```

## Data persistence

Two Docker named volumes store data on the host:

| Volume | Host path | Container mount | Content |
|--------|-----------|-----------------|---------|
| `wordpress` | `/home/iubieta-/data/wordpress` | `/var/www/html` | WordPress core, themes, plugins, uploads |
| `mariadb` | `/home/iubieta-/data/mariadb` | `/var/lib/mysql` | MariaDB data files |

Volumes are configured with the `local` driver and a bind-mount device option so that data lives at the specified host path instead of the default `/var/lib/docker/volumes/`.

## Project structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/              # Gitignored — passwords and TLS key
├── docs/                 # Reference guides
├── res/                  # Images and diagrams
└── srcs/
    ├── docker-compose.yml
    ├── .env / .env.example
    └── requirements/
        ├── mariadb/      # Dockerfile, conf/, tools/
        ├── nginx/        # Dockerfile, conf/, tools/
        ├── wordpress/    # Dockerfile, conf/, tools/
        └── tools/        # Shared scripts
```
