sudo apt-get update

# Install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.bashrc
nvm install v18.20.4

# Install PM2
sudo npm install -g pm2

# Clone repository
git clone -b ecommerce-ms https://github.com/roxsross/devops-static-web.git
cd devops-static-web/

# Install dependencies each app
cd frontend/ && npm install
cd merchandise/ && npm install
cd products/ && npm install
cd shopping-cart/ && npm install

# Deploy backend merchandise
pm2 start merchandise/server.js --name merchandise

# Deploy backend merchandise
pm2 start products/server.js --name products

# Deploy backend merchandise
pm2 start shopping-cart/server.js --name shopping-cart

# Deploy frontend
pm2 start frontend/server.js --name frontend

# Add restart automatic when server restart
pm2 startup
## the result from command to execute cmd

# Save state from apps
pm2 save

# Install Nginx
sudo apt install nginx

# Config Nginx
# paste from ./nginx.conf
sudo nano /etc/nginx/sites-available/challenge02
sudo ln -s /etc/nginx/sites-available/challenge02 /etc/nginx/sites-enabled
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx