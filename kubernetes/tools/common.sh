#!/bin/bash

# Import colors
source ./colors.sh

TIME=$(date +'%H:%M:%S')

banner() {
    clear
    echo -e "
${RED} __        __ ${GREEN} _   _       _      ${RESET}
${RED} \ \      / / ${GREEN}| | | |     | |     ${RESET}
${RED}  \ \ /\ / /  ${GREEN}| | | |     | |     ${RESET}
${RED}   \ V  V /   ${GREEN}| | | |____ | |____ ${RESET}
${RED}    \_/\_/    ${GREEN}|_| |______||______|${RESET}v{1.0#${SPURPLE}devops${RESET}} by @WilliamKidefw
${SPURPLE}WillDevelop${RESET} Automated installer\n\n"
}

checkPrivileges(){
    echo "[*] start at $(date)"
    echo -e "[*] ${GREEN}WillDevelop${RESET} \n\n"
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "Oops! You must run this tools using root/superuser privileges."
    exit
    fi
}

log() {
    local level=$1
    local message=$2
    case $level in
        "INFO") echo -e "${GREEN}[INFO]${RESET} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${RESET} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${RESET} $message" ;;
    esac
}

check_error() {
    if [ $? -ne 0 ]; then
        log "ERROR" "$1"
        exit 1
    fi
}

install_package() {
    local package=$1
    if ! dpkg -l "$package" > /dev/null 2>&1; then
        log "WARN" "Installing $package..."
        apt-get update -qq && apt-get install -y "$package" > /dev/null 2>&1
        check_error "Error to install $package."
        log "INFO" "$package installed successfull."
    else
        log "INFO" "$package is already install."
    fi
}

installDocker(){
    if ! command -v docker &> /dev/null; then
        log "WARN" "Installing docker..."
        apt-get update && apt-get install ca-certificates curl
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        check_error "Error to install docker, check manually required"
        log "INFO" "docker install successfull"
    else
        log "INFO" "docker is already install"
    fi
}