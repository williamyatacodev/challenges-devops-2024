#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

PROJECT_ROOT="challenge-final"
DOCKER_CONTAINER="kubernetes_challenge"
DOCKER_TAG="v1.0.0"
DOCKER_TAG_APP="295kubectl-app"
DOCKER_TAG_APP_CONSUMER="295kubectl-consumer"
KUBE_NAMESPACE="wyataco"
KUBE_FILES="deploy/app.yaml deploy/consumer.yaml"

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
        VERSION="$DOCKER_TAG-$GIT_VERSION"
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

deployApp(){
    echo "[*] start at $(date)"

    DEPLOY_FILE="deploy"

    if [ -d "$DEPLOY_FILE" ]; then
        log "INFO" "directory deploy exists"
    else
        mkdir deploy
    fi

    cp -r kubernetes/*.yaml $DEPLOY_FILE/

    for FILE in $KUBE_FILES; do
        sed -i "s|\$IMAGE_TAG|$TAG_APP|g" "$FILE"
    done

    check_error "Error config kubernetes files, check manually required"
    log "INFO" "kubernetes files conf successfully"

    kubectl apply -f $DEPLOY_FILE/namespace.yaml \
    -f $DEPLOY_FILE/app-svc.yaml \
    -f $DEPLOY_FILE/app.yaml \
    -f $DEPLOY_FILE/consumer.yaml \
    -n $KUBE_NAMESPACE

    kubectl get deploy,service,pod -n $KUBE_NAMESPACE

    kubectl describe service/service-flask-app -n $KUBE_NAMESPACE

    kubectl logs deployment/app -n $KUBE_NAMESPACE
    kubectl logs deployment/consumer -n $KUBE_NAMESPACE

    sleep 120

    kubectl delete -f $DEPLOY_FILE/namespace.yaml \
        -f $DEPLOY_FILE/app-svc.yaml \
        -f $DEPLOY_FILE/app.yaml \
        -f $DEPLOY_FILE/consumer.yaml \
        -n $KUBE_NAMESPACE
}

banner
checkPrivileges
installDocker
checkDockerHub "$@"
buildApp
deployApp
