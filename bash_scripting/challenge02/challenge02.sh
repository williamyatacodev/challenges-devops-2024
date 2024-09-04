#!/bin/bash

source ../tools/colors.sh
source ../tools/common.sh

packages=("curl" "nginx" "python3")

ROOT_PROJECT="devops-static-web"
GIT_PROJECT="https://github.com/roxsross/devops-static-web.git"
GIT_BRANCH="booklibrary"
NGINX_CONFIG="/etc/nginx/sites-available/challenge02"
NGINX_CONFIG_FILE="nginx.conf"
GUNICORN_CONFIG="/etc/systemd/system/challenge02.service"
GUNICORN_CONFIG_FILE="gunicorn.service.conf"

checkPython(){
    echo "[*] start at $(date)"

    if ! command -v python3 &> /dev/null; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing python"
        apt update -qq && add-apt-repository ppa:deadsnakes/ppa -y && apt install software-properties-common -y
        apt update -qq && apt install python3 -y && apt-get install -y python3-venv
        curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm get-pip.py
        check_error "Error to install python, check manually required"
        echo -e "[${GREEN}python install successfull${RESET}]"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}python${RESET} is already installed"
    fi
}

checkPip(){
    echo "[*] start at $(date)"

    if ! command -v pip &> /dev/null; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing pip"
        curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm get-pip.py
        check_error "Error to install pip, check manually required"
        echo -e "[${GREEN}pip install successfull ${RESET}]"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}pip${RESET} is already installed"
    fi
}

configGunicorn(){
    echo "[*] start at $(date)"

    if [ -f "$GUNICORN_CONFIG" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}gunicorn${RESET} config exists"
    else
        sed -i "s|\$USER|$USER_NAME|g" "$GUNICORN_CONFIG_FILE"
        sed -i "s|\$HOME|$PROJECT_HOME|g" "$GUNICORN_CONFIG_FILE"
        cp "$GUNICORN_CONFIG_FILE" "$GUNICORN_CONFIG"
        check_error "Error create config gunicorn, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] gunicorn conf successfully"
    fi

    if systemctl list-units --type=service | grep -q "challenge02.service"; then
        SERVICE_STATUS=$(systemctl is-active challenge02.service)
        if [ "$SERVICE_STATUS" == "active" ]; then
            echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}gunicorn${RESET} is activated"
        else
            echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] ${GREEN}gunicorn status $SERVICE_STATUS ${RESET}, check manually required"
            exit 1
        fi
    else
        sudo systemctl start challenge02
        check_error "Error to start gunicorn, check manually required"
        sudo systemctl enable challenge02
        check_error "Error to enable gunicorn, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] gunicorn enabled"
    fi

    # sudo systemctl status challenge02
    # check_error "Error to status gunicorn."
}

configNginx(){
    echo "[*] start at $(date)"

    if [ -f "$NGINX_CONFIG" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}Nginx${RESET} config exists"
    else
        sed -i "s|\$HOME|$PROJECT_HOME|g" "$NGINX_CONFIG_FILE"
        cp $NGINX_CONFIG_FILE "$NGINX_CONFIG"
        check_error "Error create config Nginx, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx conf successfully"
    fi

    if [ ! -f /etc/nginx/sites-enabled/challenge02 ]; then
        ln -s $NGINX_CONFIG /etc/nginx/sites-enabled
        check_error "Error to enable app in Nginx, check manually required"
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx enabled"
    fi

    if [ -f /etc/nginx/sites-enabled/default ]; then
        unlink /etc/nginx/sites-enabled/default
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Nginx default disabled"
    fi

    nginx -t
    check_error "Error config nginx, check manually required"

    systemctl restart nginx
    check_error "Error to reset nginx, check manually required"
}

configPython(){
    echo "[*] start at $(date)"

    VIRTUALENV=".challenge02"

    checkPip

    if pip show virtualenv &> /dev/null; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}virtualenv ${RESET} is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing virtualenv"
        pip install virtualenv
        apt update -qq && apt-get install -y python3-venv
        check_error "Error to install virtualenv, check manually required"
    fi
}

checkDependenciesApp(){
    echo "[*] start at $(date)"

    cp ../requirements.txt requirements.txt

    missing_packages=0

    while IFS= read -r package; do
        if [[ "$package" =~ ^# ]] || [[ -z "$package" ]]; then
            continue
        fi
        pkg_name=$(echo "$package" | sed 's/[<>=].*//')
        if ! pip show "$pkg_name" &> /dev/null; then
            echo -e "${YELLOW} $pkg_name ${RESET} not installed"
            missing_packages=$((missing_packages + 1))
        fi
    done < "requirements.txt"

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
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Clone repository"
		git clone -b $GIT_BRANCH $GIT_PROJECT
        check_error "Error to clone repository, check manually required"
		cd $ROOT_PROJECT
	fi

    if [ -d "$VIRTUALENV" ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}virtualenv ${RESET} $VIRTUALENV exists"
    else
        python3 -m venv .challenge02
        check_error "Error to create virtualenv, check manually required"
    fi

    if [[ "$VIRTUAL_ENV" == "" ]]; then
        source .challenge02/bin/activate
        check_error "Error to activate virtualenv, check manually required"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}virtualenv ${RESET} $VIRTUALENV activated"
    fi
    
    checkDependenciesApp

    if [ $missing_packages -eq 0 ]; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}All dependencies ${RESET}are already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${YELLOW} $missing_packages ${RESET} are not installed"
        pip install -r requirements.txt
    fi

    if pip show gunicorn &> /dev/null; then
        echo -e "[${LBLUE}${TIME}${RESET}] [${LGREEN}INFO${RESET}] ${GREEN}gunicorn ${RESET}is already installed"
    else
        echo -e "[${LBLUE}${TIME}${RESET}] [${GREEN}INFO${RESET}] Installing gunicorn"
        pip install gunicorn
        check_error "Error to install gunicorn"
    fi

    USER_NAME=$(whoami)
    PROJECT_HOME=$(pwd)

    deactivate && cd ..

    ROOT_HOME=$(eval echo ~$SUDO_USER)
    chmod -R 755 $ROOT_HOME

    configGunicorn
    configNginx

    echo -e "[${GREEN}DONE${RESET}]"
}

banner
checkPrivileges

## Install packages
for package in "${packages[@]}"; do
    install_package "$package"
done

checkPython
configPython
deployApp