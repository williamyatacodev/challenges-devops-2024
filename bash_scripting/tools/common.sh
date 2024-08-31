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
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] Oops! You must run this tools using root/superuser privileges."
    exit
    fi
}

check_error() {
    if [ $? -ne 0 ]; then
        echo -e "[${RED}ERROR${RESET}]" "$1"
        exit 1
    fi
}

install_package() {
    local package=$1
    if ! dpkg -l "$package" > /dev/null 2>&1; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing $package"
        apt-get update -qq && apt-get install -y "$package" > /dev/null 2>&1
        check_error "Error to install $package."
        echo -e "[${GREEN}$package install successfull${RESET}]"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}$package${RESET} is already installed"
    fi
}