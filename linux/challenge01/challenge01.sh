# Install dependencies
pip install virtualenv
# (optional) sudo apt install python3.XX-venv

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
# (optional) sudo gunicorn --bind 0.0.0.0:5000 library_site:app
deactivate

# Config Gunicorn
# paste from gunicorn.service.conf
sudo nano /etc/systemd/system/challenge01.service
sudo systemctl start challenge01
sudo systemctl enable challenge01
sudo systemctl status challenge01

# Install Nginx
sudo apt install nginx

# Config Nginx
# paste from nginx.conf
sudo nano /etc/nginx/sites-available/challenge01
sudo ln -s /etc/nginx/sites-available/challenge01 /etc/nginx/sites-enabled
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo chmod -R 755 $HOME
sudo systemctl restart challenge01
sudo systemctl restart nginx