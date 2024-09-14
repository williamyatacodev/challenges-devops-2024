#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

GIT_PROJECT="bootcamp-devops-2023"
GIT_PROJECT_URL="https://github.com/roxsross/bootcamp-devops-2023.git"
GIT_BRANCH="ejercicio2-dockeriza"
PROJECT_ROOT="295topics-fullstack"
DOCKER_FILE="docker-compose.yaml"
MONGO_USER_NAME="295topics_admin" # change your by criteria
MONGO_PASS="295topics_pass" # change your by criteria
MONGO_EXPRESS_AUTH_USER_NAME="295topics_auth" # change your by criteria
MONGO_EXPRESS_AUTH_PASS="295topics_pass" # change your by criteria
MONGO_EXPRESS_USER_NAME="295topics_user" # change your by criteria
MONGO_EXPRESS_PASS="295topics_pass" # change your by criteria
DOCKER_CONTAINER="295topics"

deployApp(){
    echo "[*] start at $(date)"

    if [ -d $GIT_PROJECT ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Repository exists ${RESET} searching for updates"
		sleep 1
		cd $GIT_PROJECT/$PROJECT_ROOT
		git pull origin $GIT_BRANCH
        check_error "Error to update repository, check manually required"
	else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}INFO${RESET}] Cloning repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT_URL
        check_error "Error to clone repository, check manually required"
        cd $GIT_PROJECT/$PROJECT_ROOT
	fi

    if [ -f "$DOCKER_FILE" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}docker compose${RESET} file exists"
    else
        cp "../../$DOCKER_FILE"  "$DOCKER_FILE"
        cp -r ../../Dockerfile* .
        sed -i "s|\$MONGO_USER_NAME|$MONGO_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_PASS|$MONGO_PASS|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_AUTH_USER_NAME|$MONGO_EXPRESS_AUTH_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_AUTH_PASS|$MONGO_EXPRESS_AUTH_PASS|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_USER_NAME|$MONGO_EXPRESS_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_PASS|$MONGO_EXPRESS_PASS|g" "$DOCKER_FILE"
        check_error "Error create config docker compose, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] docker compose conf successfully"
    fi

    if [ "$(docker ps -q -f name=^$DOCKER_CONTAINER)" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Containers${RESET} are already up"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}Containers $DOCKER_CONTAINER${RESET}] isn't up"
        if [ "$(docker ps -a -q -f name=^$DOCKER_CONTAINER)" ]; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Containers $DOCKER_CONTAINER${RESET} are starting"
            docker compose -p $DOCKER_CONTAINER start
            check_error "Error to start containers, check manually required"
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Containers $DOCKER_CONTAINER${RESET} not exists, creating"
            docker compose -p $DOCKER_CONTAINER up -d
            check_error "Error to up containers, check manually required"
        fi
    fi

    # sleep 60
    # docker compose -p $DOCKER_CONTAINER down

    echo -e "[${GREEN}DONE${RESET}]"
}

banner
checkPrivileges
installDocker
deployApp
