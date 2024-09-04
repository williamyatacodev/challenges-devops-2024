#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

packages=("curl" "nginx")

ROOT_PROJECT="devops-static-web"
GIT_PROJECT="https://github.com/roxsross/devops-static-web.git"
GIT_BRANCH="ecommerce-ms"
CONFIG_NGINX="/etc/nginx/sites-available/challenge01"

checkNvm(){
    echo "[*] start at $(date)"

    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}NVM${RESET} is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] ${RED}NVM${RESET} is not installed, trying to install..."
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Updating repository"
        `sudo apt -qq -y update &> /dev/null`
        wait
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing NVM"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        source ~/.bashrc
        export NVM_DIR="$HOME/.nvm"
        check_error "Error to install nvm"
    fi
}

checkNode(){
    echo "[*] start at $(date)"
    if command -v nodejs > /dev/null 2>&1; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Nodejs${RESET} is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] ${RED}Nodejs${RESET} is not installed, trying to install..."
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Updating repository"
        `apt -qq -y update &> /dev/null`
        wait
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing Nodejs"
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        apt-get install -y nodejs
        check_error "Error to install node"
        if  ! dpkg -l | grep -q nodejs; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] Failed to install Nodejs, check manually required."
        fi
     fi
}

configNginx(){
    if [ -f "$CONFIG_NGINX" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Nginx${RESET} config exists"
    else
        cp nginx.conf "$CONFIG_NGINX"
        check_error "Error create config nginx"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx conf successfully"
    fi

    if [ ! -f /etc/nginx/sites-enabled/challenge01 ]; then
        ln -s $CONFIG_NGINX /etc/nginx/sites-enabled
        check_error "Error to enable app in Nginx."
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx enabled"
    fi

    if [ -f /etc/nginx/sites-enabled/default ]; then
        unlink /etc/nginx/sites-enabled/default
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx default disabled"
    fi

    nginx -t
    check_error "Error config nginx."

    systemctl restart nginx
    check_error "Error to reset nginx."
}

checkPM2(){

    echo "[*] start at $(date)"
    if npm list -g --depth=0 | grep -q "pm2@"; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}pm2${RESET} is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${RED}ERROR${RESET}] ${RED}pm2${RESET} is not installed, trying to install..."
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing pm2"
        npm install -g pm2
        check_error "Error to install pm2"
     fi
}

check_dependencies_app() {
    local app=$1
    if [ -d "$app/node_modules" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Dependencies of $app ${RESET} is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing Dependencies $app"
        cd $app/ && npm install && cd ..
        check_error "Error to install dependencies of $app"
    fi
}

check_deploy_app() {
    local app=$1
    if pm2 list 2> /dev/null | grep -q $app; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}App $app ${RESET} is already up"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Up $app ------->> "
        pm2 start $app/server.js --name $app
        check_error "Error to deploy app $app"
    fi
}

deployApp(){

    if [ -d $ROOT_PROJECT ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Repository exists ${RESET} searching for updates"
		sleep 1
		cd $ROOT_PROJECT
		git pull origin $GIT_BRANCH
        check_error "Error to update repository"
	else
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Clone repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT
        check_error "Error to clone repository"
		cd $ROOT_PROJECT
	fi

    # Install dependencies each apps
    echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Install Dependencies to apps${RESET}"

    apps=("frontend" "merchandise" "products" "shopping-cart")

    for app in "${apps[@]}"; do
        check_dependencies_app "$app"
    done

    for app in "${apps[@]}"; do
        check_deploy_app "$app"
    done

    # Add restart automatic when server restart
    # pm2 startup > pm2_startup.txt
    # check_error "Error al ejecutar pm2 startup"

    # Save state from apps
    pm2 save
    echo -e "[${GREEN}DONE${RESET}]"

}

banner
checkPrivileges

# Install packages
for package in "${packages[@]}"; do
    install_package "$package"
done

# checkNvm
checkNode
checkPM2
configNginx
deployApp
