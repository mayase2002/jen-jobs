#!/bin/bash

export IMAGE=$1
export DOCKER_USER=$2
export DOCKER_PWD=$3
echo $DOCKER_PWD | docker login -u $DOCKER_USER --pasword-stdn
docker-compose -f docker-compose.yaml up --detach
echo "success"