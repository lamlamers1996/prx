#!/bin/bash

# Default values
START_PORT=46996
DEFAULT_USERNAME="bang"

# Function to generate a random password
generate_password() {
    openssl rand -base64 12
}

# Enable the ports using ufw
echo "Enabling ports..."
for ((i=0; i<20; i++)); do
    PORT=$((START_PORT + i))
    sudo ufw allow $PORT
    echo "Enabled port $PORT"
done

# Create secrets.txt file with default username and unique passwords
echo "Creating secrets file..."
for ((i=0; i<20; i++)); do
    PASSWORD=$(generate_password)
    echo "$DEFAULT_USERNAME $PASSWORD" | sudo tee -a /root/secrets.txt > /dev/null
    echo "Created user $DEFAULT_USERNAME with password $PASSWORD for port $((START_PORT + i))"
done

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

# Create and edit Gost service files for IPv6
echo "Creating Gost service files..."
for ((i=0; i<20; i++)); do
    PORT=$((START_PORT + i))
    cat <<EOF | sudo tee /etc/systemd/system/gost${PORT}.service
[Unit]
Description=Gost Proxy Server on port $PORT
After=network.target

[Service]
Type=simple
ExecStart=/snap/bin/gost -L=socks5://[::]:$PORT?secrets=/root/secrets.txt
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    echo "Created service file for port $PORT"
done

# Reload daemon of systemctl
sudo systemctl daemon-reload

# Start and enable all Gost services to start on boot
echo "Starting and enabling Gost services..."
for ((i=0; i<20; i++)); do
    PORT=$((START_PORT + i))
    sudo systemctl start gost${PORT}
    sudo systemctl enable gost${PORT}
    echo "Started and enabled Gost service on port $PORT"
done

echo "Setup completed!"
