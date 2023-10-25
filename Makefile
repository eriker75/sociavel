IMAGE_NAME = phpapp-image
CONTAINER_NAME = phpapp-container
COMPOSE_PROJECT_NAME = phpapp-compose
USER_ID = $(shell id -u)
USER_GROUP = $(shell id -g)

.PHONY: build run composer

build:
		docker build -t $(IMAGE_NAME) --build-arg USER_ID=$(USER_ID) .

run:
		docker run -d --name $(CONTAINER_NAME) -p 8080:80 -v ./app:/var/www/html $(IMAGE_NAME)

up: build run

bash:
		docker exec -it $(CONTAINER_NAME) bash

stop:
		docker stop $(CONTAINER_NAME)

rm:
		docker rm $(CONTAINER_NAME)

rmi:
		docker rmi $(IMAGE_NAME) 

down: stop rm rmi

compose-restart:
		docker exec -it $(CONTAINER_NAME) service apache2 restart

compose-reload:
		docker exec -it $(CONTAINER_NAME) service apache2 reload  

compose-logs:
		docker logs $(CONTAINER_NAME) -f --tail 100 

compose-build:
		docker-compose -p $(COMPOSE_PROJECT_NAME) build

compose-up:
		docker-compose -p $(COMPOSE_PROJECT_NAME) up --build -d

compose-down:
		docker-compose -p $(COMPOSE_PROJECT_NAME) down

compose-bash:
		docker-compose -p $(COMPOSE_PROJECT_NAME) exec web bash

logs:
		docker-compose -p $(COMPOSE_PROJECT_NAME) logs -f --tail=100