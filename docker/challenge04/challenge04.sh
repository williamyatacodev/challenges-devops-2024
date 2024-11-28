#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

GIT_PROJECT="bootcamp-devops-2023"
GIT_PROJECT_URL="https://github.com/roxsross/bootcamp-devops-2023.git"
GIT_BRANCH="ejercicio2-dockeriza"
PROJECT_ROOT="295words-docker"
DOCKER_FILE="docker-compose.yaml"
DOCKER_CONTAINER="295words"
DOCKER_TAG_APP="v1.0.0"
DOCKER_TAG_APP_DATABASE="295words-db"
DOCKER_TAG_APP_BACKEND="295words-api"
DOCKER_TAG_APP_FRONTEND="295words-frontend"

checkDockerHub(){
    echo "[*] start at $(date)"
    if [ "$#" -ne 2 ]; then
        log "ERROR" "No arguments supplied DOCKER_USERNAME and DOCKER_PASSWORD"
        exit 1
    fi

    DOCKER_USERNAME=$1
    DOCKER_PASSWORD=$2
}

checkDockerImages(){
    echo "[*] start at $(date)"

    declare -A DOCKER_FILES=(
        [$DOCKER_TAG_APP_DATABASE]="Dockerfile.database"
        [$DOCKER_TAG_APP_BACKEND]="Dockerfile.backend"
        [$DOCKER_TAG_APP_FRONTEND]="Dockerfile.frontend"
    )

    for IMAGE in "${!IMAGES_AND_VERSIONS[@]}"; do
        VERSION=${IMAGES_AND_VERSIONS[$IMAGE]}
        DOCKERFILE=${DOCKER_FILES[$IMAGE]}

        if ! checkDockerImageExists "$IMAGE" "$VERSION"; then
            publishDockerImages "$IMAGE" "$VERSION" "$DOCKERFILE"
        fi
    done
}

checkDockerImageExists() {
    local IMAGE=$1
    local VERSION=$2
    local EXISTS=$(curl -s -o /dev/null -w "%{http_code}" "https://hub.docker.com/v2/repositories/$DOCKER_USERNAME/$IMAGE/tags/$VERSION/")

    if [ "$EXISTS" -eq 200 ]; then
        log "INFO" "Image $IMAGE:$VERSION exist in Docker Hub"
        return 0
    else
        log "INFO" "Image $IMAGE:$VERSION not exist in Docker Hub"
        return 1
    fi
}

publishDockerImages(){
    local IMAGE=$1
    local VERSION=$2
    local DOCKERFILE=$3

    log "WARN" "Publish $IMAGE:$VERSION..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

    docker build -t "$DOCKER_USERNAME/$IMAGE:$VERSION" -f "$DOCKERFILE" .
    check_error "Error build docker $IMAGE:$VERSION, check manually required"

    docker push "$DOCKER_USERNAME/$IMAGE:$VERSION"
    check_error "Error publish docker $IMAGE:$VERSION, check manually required"

    echo "Image $IMAGE:$VERSION published in Docker Hub."
    docker logout
}

getTagVersion() {
    local GIT_VERSION=$(git describe --tags --long --always)
    
    if [[ "$GIT_VERSION" =~ ^[0-9a-f]{7,}$ ]]; then
        VERSION="$DOCKER_TAG_APP-$GIT_VERSION"
    fi

    echo "$VERSION"
}

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
        sed -i "s|\$DOCKER_HUB_USERNAME|$DOCKER_USERNAME|g" "$DOCKER_FILE"
        check_error "Error config docker compose, check manually required"
        log "INFO" "docker compose conf successfully"
    fi

    TAG_APP=$(getTagVersion)

    declare -A IMAGES_AND_VERSIONS=(
        [$DOCKER_TAG_APP_DATABASE]="$TAG_APP"
        [$DOCKER_TAG_APP_BACKEND]="$TAG_APP"
        [$DOCKER_TAG_APP_FRONTEND]="$TAG_APP"
    )

    checkDockerImages
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

    log "INFO" "DONE"
}

banner
checkPrivileges
installDocker
checkDockerHub "$@"
buildApp
deployApp