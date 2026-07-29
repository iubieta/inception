COMPOSE   = docker compose -f srcs/docker-compose.yml
DATA_DIR  = /home/iubieta-/data

SECRET_FILES = db_password.txt db_root_password.txt \
               wp_admin_password.txt wp_user_password.txt \
               site.crt site.key

.PHONY: all build up down stop start restart logs ps clean fclean re check-env prepare certs

all: check-env prepare build up

check-env:
	@test -f srcs/.env || (echo "Missing srcs/.env (copy it from srcs/.env.example)" && exit 1)
	@for f in $(SECRET_FILES); do \
		test -f secrets/$$f || (echo "Missing secrets/$$f (see docs/env-and-secrets.md)" && exit 1); \
	done
	@echo "check-env: all good"

DOMAIN_NAME := $(shell grep -s '^DOMAIN_NAME' srcs/.env | cut -d= -f2)

certs:
	DOMAIN_NAME="$(DOMAIN_NAME)" CERT_DIR=./secrets srcs/nginx/tools/cert-gen.sh

prepare: certs
	mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	docker system prune -f

fclean: clean
	sudo rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	docker volume prune -f

re: fclean all
