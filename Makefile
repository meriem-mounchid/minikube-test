NAME = intranet
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

all : $(NAME)

$(NAME): build startd

build:
    docker-compose -f $(DOCKER_COMPOSE_FILE) build

start:
    docker-compose -f $(DOCKER_COMPOSE_FILE) up

startd:
    docker-compose -f $(DOCKER_COMPOSE_FILE) up -d

stop:
    docker-compose -f $(DOCKER_COMPOSE_FILE) stop

down:
    docker-compose -f $(DOCKER_COMPOSE_FILE) down --remove-orphans

clean:
    sudo docker-compose down --rmi all

retry: clean startd

reload:
    docker-compose -f $(DOCKER_COMPOSE_FILE) up -d --build

fclean: down clean
    docker image prune -af

re: fclean all

prune_all:
    docker system prune --volumes -fa

fre: fclean all

purge:
    docker stop $$(docker ps -qa)  true
    docker rm $$(docker ps -qa)  true
    docker rmi -f $$(docker images -qa)  true
    docker volume rm $$(docker volume ls -q)  true
    docker network rm $$(docker network ls -q) 2>/dev/null || true