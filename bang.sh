#!/bin/bash

# Default values
DEFAULT_PORT=6789
DEFAULT_USERNAME="admin"
DEFAULT_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

# Get the IP address of the machine
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Enable the port using ufw
sudo ufw allow $DEFAULT_PORT

# Create secrets.txt file with default username and password
echo "$DEFAULT_USERNAME $DEFAULT_PASSWORD" | sudo tee /root/secrets.txt > /dev/null

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
ExecStart=/snap/bin/gost -L=socks5://:$DEFAULT_PORT?secrets=/root/secrets.txt
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
#!/bin/bash

echo "  ____   _     _        ____  _    _   _  ______ "
echo " / ___| | |   (_)      / ___|| |  | | | |/ / ___|"
echo " \___ \ | |    _ _____| |  _ | |  | | | ' /\___ \\"
echo "  ___) || |___| |_____| |_| || |__| | | . \ ___) |"
echo " |____(_|_____|_|      \____(_\____/  |_|\_\____(_)"
echo " "
echo " "
echo " "
echo " "

# Output the generated information
echo "tạo thành cồn proxy: $IP_ADDRESS:$DEFAULT_PORT:$DEFAULT_USERNAME:$DEFAULT_PASSWORD"
