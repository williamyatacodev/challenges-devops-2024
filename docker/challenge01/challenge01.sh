#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

DOCKER_COMPOSE_FILE="docker-compose.yaml"
DOCKER_COMPOSE_DEPLOY_FILE="docker-compose-deploy.yaml"
MONGO_USER="admin" # change your by criteria
MONGO_PASSWORD="pass01" # change your by criteria
MONGO_EXPRESS_USER="user" # change your by criteria
MONGO_EXPRESS_PASSWORD="pass2" # change your by criteria
DOCKER_CONTAINER="challenge01"

configDocker(){
    echo "[*] start at $(date)"

    if [ -f "$DOCKER_COMPOSE_DEPLOY_FILE" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Docker${RESET} compose exists"
    else
        cp $DOCKER_COMPOSE_FILE $DOCKER_COMPOSE_DEPLOY_FILE
        sed -i "s|\$MONGO_USER|$MONGO_USER|g" "$DOCKER_COMPOSE_DEPLOY_FILE"
        sed -i "s|\$MONGO_PASS|$MONGO_PASSWORD|g" "$DOCKER_COMPOSE_DEPLOY_FILE"
        sed -i "s|\$MONGO_EXPRESS_USER|$MONGO_EXPRESS_USER|g" "$DOCKER_COMPOSE_DEPLOY_FILE"
        sed -i "s|\$MONGO_EXPRESS_PASS|$MONGO_EXPRESS_PASSWORD|g" "$DOCKER_COMPOSE_DEPLOY_FILE"
        check_error "Error config docker compose, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Docker compose config successfully"
    fi
}

deployMongo(){
    echo "[*] start at $(date)"

    if [ "$(docker ps -q -f name=$DOCKER_CONTAINER)" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container${RESET} is already up"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}Container $DOCKER_CONTAINER${RESET}] isn't up"
        if [ "$(docker ps -a -q -f name=$DOCKER_CONTAINER)" ]; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} is starting"
            docker compose -f $DOCKER_COMPOSE_DEPLOY_FILE start
            check_error "Error to start container, check manually required"
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} not exists, creating"
            pwd
            docker compose -f $DOCKER_COMPOSE_DEPLOY_FILE up -d
            check_error "Error to up container, check manually required"
        fi
    fi
}

banner
checkPrivileges

installDocker
configDocker
deployMongo