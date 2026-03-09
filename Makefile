NAME := inception
COMPOSE := docker compose
FILE := srcs/docker-compose.yml

MARIADB_DATA := /home/ekirsner/data/mariadb
WORDPRESS_DATA := /home/ekirsner/data/wordpress
MARIADB_FLAG := $(MARIADB_DATA)/.db_initialized

.PHONY: all up down build re clean fclean ps logs reset_db reset_all reset_db_init

all: up

build:
	$(COMPOSE) -f $(FILE) build

up:
	$(COMPOSE) -f $(FILE) up -d --build

down:
	$(COMPOSE) -f $(FILE) down

re: down up

clean:
	$(COMPOSE) -f $(FILE) down -v

reset_db_init:
	$(COMPOSE) -f $(FILE) down
	sudo rm -f $(MARIADB_FLAG)

reset_db:
	$(COMPOSE) -f $(FILE) down -v
	sudo rm -rf $(MARIADB_DATA)
	sudo mkdir -p $(MARIADB_DATA)

reset_all:
	$(COMPOSE) -f $(FILE) down -v
	sudo rm -rf $(MARIADB_DATA) $(WORDPRESS_DATA)
	sudo mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)

fclean: reset_all
	docker system prune -af

ps:
	$(COMPOSE) -f $(FILE) ps

logs:
	$(COMPOSE) -f $(FILE) logs -f