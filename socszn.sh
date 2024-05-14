#!/bin/bash

# Ask for port number
read -p "Enter the port number you want to use: " PORT
# Ask for username
read -p "Enter your username: " USERNAME

# Ask for password (without echoing characters)
read -s -p "Enter your password: " PASSWORD

# Enable the port using ufw
sudo ufw allow $PORT
 
# Create secrets.txt file with username and password
echo "$USERNAME $PASSWORD" | sudo tee /root/secrets.txt > /dev/null

# Install Git
sudo apt update
sudo apt install -y git

# Install Go
wget -q https://golang.org/dl/go1.17.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install Snap
sudo apt install -y snapd

# Clone repository
git clone https://github.com/ginuerzh/gost.git

# Navigate to gost directory
cd gost/cmd/gost

# Build gost
go build

# Install snap core
sudo snap install core

# Install gost via snap
sudo snap install gost

# Create and edit Gost service file
cat <<EOF | sudo tee /etc/systemd/system/gost.service
[Unit]
Description=Gost Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/snap/bin/gost -L=socks5://:$PORT?secrets=/root/secrets.txt
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon of systemctl
sudo systemctl daemon-reload

# Start Gost service
sudo systemctl start gost

# Enable Gost service to start on boot
sudo systemctl enable gost
