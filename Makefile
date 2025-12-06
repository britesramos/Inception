NAME = inception
DATA_DIR = $(HOME)/data
COMPOSE_FILE = srcs/docker-compose.yaml

GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

all: up

up:
	@echo "$(YELLOW)Creating data directories...$(NC)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@echo "$(GREEN)Directories created!$(NC)"
	@echo "$(YELLOW)Building and starting containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Containers are up!$(NC)"

build:
	@echo "$(YELLOW)Building images...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build

down:
	@echo "$(YELLOW)Stopping and removing containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)Containers stopped!$(NC)"

stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) stop

start:
	@echo "$(YELLOW)Starting containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) start

restart: down up

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

logs-mariadb:
	@docker logs -f mariadb

logs-wordpress:
	@docker logs -f wordpress

logs-nginx:
	@docker logs -f nginx

ps:
	@docker-compose -f $(COMPOSE_FILE) ps

clean: down
	@rm -rf $(DATA_DIR)/mariadb/*
	@rm -rf $(DATA_DIR)/wordpress/*
	@echo "$(YELLOW)Cleaning Docker system...$(NC)"
	@docker system prune -af
	@echo "$(GREEN)Docker system cleaned!$(NC)"

fclean: down
	@echo "$(RED)Removing all containers, images, volumes, and data...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	@docker system prune -af --volumes
	@echo "$(YELLOW)Removing data directories...$(NC)"
	@docker run --rm -v $(DATA_DIR):/data alpine sh -c "rm -rf /data/*"
	@echo "$(GREEN)Full clean complete!$(NC)"

re: fclean all

status:
	@echo "$(YELLOW)=== Container Status ===$(NC)"
	@docker ps -a --filter "name=mariadb" --filter "name=wordpress" --filter "name=nginx"
	@echo "\n$(YELLOW)=== Volume Status ===$(NC)"
	@docker volume ls | grep inception || echo "No inception volumes found"
	@echo "\n$(YELLOW)=== Network Status ===$(NC)"
	@docker network ls | grep inception || echo "No inception network found"

test-mariadb:
	@echo "$(YELLOW)Testing MariaDB connection...$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep SQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SHOW DATABASES;"

test-wordpress:
	@echo "$(YELLOW)Testing WordPress installation...$(NC)"
	@docker exec wordpress wp core version --allow-root --path=/var/www/wordpress

test-nginx:
	@echo "$(YELLOW)Testing Nginx...$(NC)"
	@docker exec nginx nginx -t

test-connection:
	@echo "$(YELLOW)Testing full connection...$(NC)"
	@echo "1. PHP-FPM process:"
	@docker exec wordpress ps aux | grep php-fpm | grep -v grep || echo "❌ Not running"
	@echo "\n2. Testing from host:"
	@curl -L -k -s https://localhost:8443 | head -50

test-curl:
	@curl -v -k https://localhost:8443

test-all: test-mariadb test-wordpress test-nginx test-connection

shell-mariadb:
	@docker exec -it mariadb /bin/bash

shell-wordpress:
	@docker exec -it wordpress /bin/bash

shell-nginx:
	@docker exec -it nginx /bin/bash


.PHONY: all up build down stop start restart logs logs-mariadb logs-wordpress logs-nginx ps clean fclean re status test-mariadb test-wordpress test-nginx test-connection test-all test-curl shell-mariadb shell-wordpress shell-nginx