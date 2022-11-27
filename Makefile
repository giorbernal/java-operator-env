#!/bin/bash

LOCAL_PATH=/Users/bernal/Documents/ext/GitInception/java-operator-env/operators
NAME=jk8sopr

build:
	docker build -t ${NAME} .

create:
	docker run \
	-d \
	-e KUBE_IP='192.168.1.36' \
	-v ${LOCAL_PATH}:/home/data/ \
        -v /Users/bernal/Library/Containers/com.docker.docker/Data/:/var/run/ \
	--name ${NAME} \
	${NAME}

start:
	docker start ${NAME}

enter:
	docker exec -it ${NAME} bash

stop:
	docker stop ${NAME}

remove:
	docker rm ${NAME}

destroy:
	docker rmi ${NAME}
