COMPOSE = sudo docker compose -f srcs/docker-compose.yaml
DATA_PATH = /home/yazlaigi/data

all:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	$(COMPOSE) up -d --build
down:
	$(COMPOSE) down
stop:
	$(COMPOSE) stop
start:
	$(COMPOSE) start
clean:
	$(COMPOSE) down --rmi all
fclean: clean
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_PATH)/mariadb
	sudo rm -rf $(DATA_PATH)/wordpress
re: clean
	$(MAKE) all
.PHONY: all down stop start clean fclean re