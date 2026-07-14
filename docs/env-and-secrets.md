# Environment variables & secrets reference

This file exists so that setting up the project on a new machine (a fresh VM,
a teammate's laptop, evaluation day, etc.) doesn't rely on memory. It lists
every piece of configuration the containers expect and where it must live.

> Rule of thumb used across this project:
> - **Non-confidential config** (hostnames, usernames, titles) → `srcs/.env`
> - **Confidential values** (passwords, TLS key) → `secrets/*.txt` + `secrets/site.crt` / `secrets/site.key`,
>   consumed inside containers via Docker secrets (`/run/secrets/<name>`), never as env vars.

## 1. `srcs/.env`

Committed to git (contains no secrets). Must define:

| Variable | Example | Used by | Notes |
|---|---|---|---|
| `DOMAIN_NAME` | `https://iubieta-.42.fr` | wordpress (`wp core install --url`) | Needs the `https://` scheme, not just the bare domain |
| `DB_HOST` | `mariadb` | wordpress | Must match the mariadb service name in `compose.yml` |
| `DB_NAME` | `wordpress` | mariadb, wordpress | |
| `DB_USER` | `wp` | mariadb, wordpress | |
| `WP_TITLE` | `Inception` | wordpress (`wp core install --title`) | |
| `WP_ADMIN_USER` | `iubieta` | wordpress | Must **not** contain `admin`/`administrator` (subject requirement) |
| `WP_ADMIN_EMAIL` | `ikerp.ubieta@gmail.com` | wordpress | |
| `WP_USER` | `random` | wordpress | Second, non-admin WordPress user |
| `WP_USER_EMAIL` | `random@gmail.com` | wordpress | |

## 2. `secrets/` (root of the repo, sibling of `srcs/`, gitignored via `/secrets/`)

Must contain exactly these 6 files:

| File | Docker secret name (in `compose.yml`) | Mounted at (inside container) | Consumed by |
|---|---|---|---|
| `db_password.txt` | `db_pass` | `/run/secrets/db_pass` | `mariadb/tools/db-init.sh`, `wordpress/tools/wp-init.sh` |
| `db_root_password.txt` | `db_root_pass` | `/run/secrets/db_root_pass` | `mariadb/tools/db-init.sh` |
| `wp_admin_password.txt` | `wp_admin_pass` | `/run/secrets/wp_admin_pass` | `wordpress/tools/wp-init.sh` |
| `wp_user_password.txt` | `wp_user_pass` | `/run/secrets/wp_user_pass` | `wordpress/tools/wp-init.sh` |
| `site.crt` | `site_crt` | `/run/secrets/site_crt` | nginx (`my_site.conf`) |
| `site.key` | `site_key` | `/run/secrets/site_key` | nginx (`my_site.conf`) |

> The name that matters at runtime is the **secret name** declared in `compose.yml`
> (right column), not the filename on disk. If you rename one side, rename the other.

### Recreating them from scratch on a new machine

```bash
mkdir -p secrets
cd secrets

openssl rand -hex 16 > db_password.txt
openssl rand -hex 16 > db_root_password.txt
openssl rand -hex 16 > wp_admin_password.txt
openssl rand -hex 16 > wp_user_password.txt

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout site.key -out site.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=iubieta-.42.fr"

chmod 600 db_password.txt db_root_password.txt wp_admin_password.txt wp_user_password.txt site.key
cd ..
```

Passwords don't need to be random — any value works — but they **must be
different from each other** and must never be committed anywhere outside
`secrets/` (which is gitignored).

## 3. Quick sanity check before `docker compose up`

```bash
# from repo root
test -f srcs/.env && echo ".env OK" || echo "MISSING srcs/.env"
for f in db_password.txt db_root_password.txt wp_admin_password.txt wp_user_password.txt site.crt site.key; do
  test -f "secrets/$f" && echo "secrets/$f OK" || echo "MISSING secrets/$f"
done
```
