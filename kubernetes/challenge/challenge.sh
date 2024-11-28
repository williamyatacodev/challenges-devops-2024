#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

PROJECT_ROOT="challenge-final"
DOCKER_CONTAINER="kubernetes_challenge"
DOCKER_TAG_APP="v1.0.0"
DOCKER_TAG_APP="295kubectl-app"
DOCKER_TAG_APP_CONSUMER="295kubectl-consumer"

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
        [$DOCKER_TAG_APP]="Dockerfile.app"
        [$DOCKER_TAG_APP_CONSUMER]="Dockerfile.consumer"
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

    TAG_APP=$(getTagVersion)

    declare -A IMAGES_AND_VERSIONS=(
        [$DOCKER_TAG_APP]="$TAG_APP"
        [$DOCKER_TAG_APP_CONSUMER]="$TAG_APP"
    )

    checkDockerImages
}

banner
checkPrivileges
installDocker
checkDockerHub "$@"
buildApp

# docker build -f Dockerfile.app -t test_app .
# docker run -d -p 8088:8000 test_app
# docker build -f Dockerfile.consumer -t test_consumer .
# docker run -d -p 8089:8000 test_consumer

# docker compose up -d
# docker compose down
