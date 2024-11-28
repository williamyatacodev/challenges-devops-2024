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

buildApp(){
    echo "[*] start at $(date)"

    if [ -d $GIT_PROJECT ]; then
        log "INFO" "Repository exists searching for updates"
		sleep 1
		cd $GIT_PROJECT/$PROJECT_ROOT
		git pull origin $GIT_BRANCH
        check_error "Error to update repository, check manually required"
	else
        log "WARN" "Cloning repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT_URL
        check_error "Error to clone repository, check manually required"
        cd $GIT_PROJECT/$PROJECT_ROOT
	fi

    if [ -f "$DOCKER_FILE" ]; then
        log "INFO" "docker compose file exists"
    else
        cp "../../$DOCKER_FILE"  "$DOCKER_FILE"
        cp -r ../../Dockerfile* .
        sed -i "s|\$MONGO_USER_NAME|$MONGO_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_PASS|$MONGO_PASS|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_AUTH_USER_NAME|$MONGO_EXPRESS_AUTH_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_AUTH_PASS|$MONGO_EXPRESS_AUTH_PASS|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_USER_NAME|$MONGO_EXPRESS_USER_NAME|g" "$DOCKER_FILE"
        sed -i "s|\$MONGO_EXPRESS_PASS|$MONGO_EXPRESS_PASS|g" "$DOCKER_FILE"
        check_error "Error config docker compose, check manually required"
        log "INFO" "docker compose conf successfully"
    fi
}

deployApp(){
    echo "[*] start at $(date)"

    if [ "$(docker ps -q -f name=^$DOCKER_CONTAINER)" ]; then
        log "INFO" "Containers are already up"
    else
        log "WARN" "Containers $DOCKER_CONTAINER isn't up"
        if [ "$(docker ps -a -q -f name=^$DOCKER_CONTAINER)" ]; then
            log "INFO" "Containers $DOCKER_CONTAINER are starting"
            docker compose -p $DOCKER_CONTAINER start
            check_error "Error to start containers, check manually required"
        else
            log "INFO" "Containers $DOCKER_CONTAINER not exists, creating..."
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
buildApp
deployApp
