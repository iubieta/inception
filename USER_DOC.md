# User Documentation — INCEPTION

## Services

The stack provides three services:

- **NGINX** — HTTPS reverse proxy. It is the only entrypoint to the infrastructure, exposed on port 443 with TLSv1.2/TLSv1.3.
- **WordPress + PHP-FPM** — CMS and blog platform with a web administration panel.
- **MariaDB** — Relational database that stores WordPress content and users.

## Start and stop the project

```bash
# Start everything
make

# Stop without removing containers
make stop

# Start again after a stop
make start

# Stop and remove containers
make down

# Full restart
make restart
```

All commands must be run from the repository root.

## Access the website and administration panel

- **Website**: `https://iubieta-.42.fr`
- **Admin panel**: `https://iubieta-.42.fr/wp-admin`

The domain must resolve to `127.0.0.1` in your `/etc/hosts`:

```
127.0.0.1 iubieta-.42.fr
```

## Credentials

Credentials are stored as Docker secrets and are never exposed as environment variables. Two WordPress users exist:

| User | Role | Password location |
|------|------|-------------------|
| `iubieta` | Administrator | `secrets/wp_admin_password.txt` |
| `random` | Author | `secrets/wp_user_password.txt` |

MariaDB credentials:

| Purpose | Password location |
|---------|-------------------|
| WordPress database user | `secrets/db_password.txt` |
| MariaDB root user | `secrets/db_root_password.txt` |

## Check that services are running

```bash
# Container status
make ps

# Live logs
make logs

# Verify volumes are populated
ls /home/iubieta-/data/wordpress/
ls /home/iubieta-/data/mariadb/

# Test HTTPS access
curl -vk https://iubieta-.42.fr

# Verify only TLS 1.2/1.3 are accepted
openssl s_client -connect iubieta-.42.fr:443 -tls1_1  # must fail
openssl s_client -connect iubieta-.42.fr:443 -tls1_2  # must succeed
```
