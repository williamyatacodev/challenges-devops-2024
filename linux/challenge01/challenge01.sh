# Install dependencies
pip install virtualenv

# Download repository
# git clone -b booklibrary https://github.com/roxsross/devops-static-web.git
cd devops-static-web/

# Active venv
python3 -m venv .challenge01
source .challenge01/bin/activate

# Install dependencies app
pip install -r requirements.txt

# Install Gunicorn
pip install gunicorn
deactivate

# Config Gunicorn
# paste from gunicorn.service.conf
sudo chmod 755 /root
sudo nano /etc/systemd/system/challenge01.service
sudo systemctl start challenge01
sudo systemctl enable challenge01
sudo systemctl status challenge01

# Install Nginx
apt install nginx

# Config Nginx
# paste from nginx.conf
sudo nano /etc/nginx/sites-available/challenge01
sudo ln -s /etc/nginx/sites-available/challenge01 /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx