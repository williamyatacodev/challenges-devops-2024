#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

GIT_PROJECT="devops-static-web"
GIT_PROJECT_URL="https://github.com/roxsross/devops-static-web.git"
GIT_BRANCH="devops-simple-web"
PROJECT_ROOT="bootcamp-web"
DOCKER_FILE="docker-compose.yaml"
DOCKER_CONTAINER="bootcamp-web"
NGINX_TARGET_DIR="/usr/share/nginx/html/"


deployApp(){
    echo "[*] start at $(date)"

    if [ -d $GIT_PROJECT ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Repository exists ${RESET} searching for updates"
		sleep 1
		cd $GIT_PROJECT
		git pull origin $GIT_BRANCH
        check_error "Error to update repository, check manually required"
	else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}INFO${RESET}] Cloning repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT_URL
        check_error "Error to clone repository, check manually required"
        cd $GIT_PROJECT
	fi

    if [ -f "$DOCKER_FILE" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}docker compose${RESET} file exists"
    else
        cp "../$DOCKER_FILE" "$DOCKER_FILE"
        PROJECT="${PWD}/$PROJECT_ROOT"
        sed -i "s|\$PROJECT_DIR|$PROJECT|g" "$DOCKER_FILE"
        check_error "Error create config docker compose, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] docker compose conf successfully"
    fi

    if [ "$(docker ps -q -f name=$DOCKER_CONTAINER)" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container${RESET} is already up"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}Container $DOCKER_CONTAINER${RESET}] isn't up"
        if [ "$(docker ps -a -q -f name=$DOCKER_CONTAINER)" ]; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} is starting"
            docker compose start
            check_error "Error to start container, check manually required"
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} not exists, creating"
            docker compose up -d
            check_error "Error to up container, check manually required"
        fi
    fi

    docker exec $DOCKER_CONTAINER ls "$NGINX_TARGET_DIR"
    check_error "Error to verify copy files web to nginx, check manually required"

    echo -e "[${GREEN}DONE${RESET}]"
}

banner
checkPrivileges
installDocker
deployApp