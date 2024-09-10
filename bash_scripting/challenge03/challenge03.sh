#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

ROOT_PROJECT="devops-static-web"
GIT_PROJECT="https://github.com/roxsross/devops-static-web.git"
GIT_BRANCH="devops-automation-python"
DOCKERFILE="Dockerfile"
DOCKER_CONTAINER="challenge03"
# DOCKER_TAG="wyataco/challenge03"


installDocker(){
    if ! command -v docker &> /dev/null; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing docker"
        apt-get update && apt-get install ca-certificates curl
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        # Add the repository to Apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        check_error "Error to install docker, check manually required"
        # groupadd docker
        # usermod -aG docker $USER
        # newgrp docker
        # check_error "Error to config docker, check manually required"
        echo -e "[${GREEN}docker install successfull${RESET}]"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}docker${RESET} is already installed"
    fi
}

createFolders(){

    folder="tempdir"
    files_to_copy=("desafio2_app.py" "static" "templates")

    for i in "${!files_to_copy[@]}"; do
        file="${files_to_copy[$i]}"
        if [ -e "$file" ]; then
            if [ ! -d "$folder" ]; then
                mkdir -p "$folder"
                echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] folder $folder created"
            fi
            if [ -f "$file" ]; then
                if [ -f "$folder/$(basename "$file")" ]; then
                    echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}$file${RESET} exists in $folder"
                else
                    cp "$file" "$folder"
                    echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] $file copied to $folder"
                fi
            elif [ -d "$file" ]; then
                if [ -d "$folder/$(basename $file)" ]; then
                    echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}$file${RESET} exists in $folder"
                else
                    cp -r "$file" "$folder"
                    echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] $file copied to $folder"
                fi
            fi
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${YELLOW}$file${RESET} not exists"
        fi
    done
}

deployApp(){
    echo "[*] start at $(date)"

    if [ -d $ROOT_PROJECT ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Repository exists ${RESET} searching for updates"
		sleep 1
		cd $ROOT_PROJECT
		git pull origin $GIT_BRANCH
        check_error "Error to update repository, check manually required"
	else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}INFO${RESET}] Cloning repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT
        check_error "Error to clone repository, check manually required"
		cd $ROOT_PROJECT
	fi

    createFolders

    cd tempdir

    if [ -d $DOCKERFILE ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Dockerfile${RESET} is already exists"
    else
        cp -r ../../$DOCKERFILE $DOCKERFILE
    fi

    if [ "$(docker ps -q -f name=$DOCKER_CONTAINER)" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container${RESET} is already up"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${YELLOW}Container $DOCKER_CONTAINER${RESET}] isn't up"
        if [ "$(docker ps -a -q -f name=$DOCKER_CONTAINER)" ]; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} is starting"
            docker start $DOCKER_CONTAINER
            check_error "Error to start container, check manually required"
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Container $DOCKER_CONTAINER${RESET} not exists, creating"
            pwd
            docker build -t $DOCKER_CONTAINER .
            docker run -t -d -p 5050:5050 --name $DOCKER_CONTAINER $DOCKER_CONTAINER
            check_error "Error to up container, check manually required"
        fi
    fi

    DOCKER_CONTAINER_ID=$(docker ps -q -f name=$DOCKER_CONTAINER)
    
    docker ps -a
    echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Show logs container $DOCKER_CONTAINER"
    docker logs $DOCKER_CONTAINER_ID
    echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Inspect container $DOCKER_CONTAINER"
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DOCKER_CONTAINER
    echo -e "[${GREEN}DONE${RESET}]"
}

banner
checkPrivileges
installDocker
deployApp
