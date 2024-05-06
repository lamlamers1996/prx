#!/bin/bash

# Cài đặt gcc và make
sudo yum install -y gcc make

# Cài đặt wget
sudo yum install -y wget

# Tải xuống Dante Proxy
wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz

# Giải nén Dante Proxy
tar xvfz dante-1.4.2.tar.gz

# Di chuyển vào thư mục Dante Proxy
cd dante-1.4.2

# Cấu hình Dante Proxy
./configure

# Biên dịch Dante Proxy
make

# Cài đặt Dante Proxy
sudo make install

# Tạo nội dung cho tập tin /etc/sockd.conf
sudo bash -c 'cat <<EOF > /etc/sockd.conf
logoutput: /var/log/socks.log
internal: eth0 port = 46996
external: eth0
clientmethod: none
socksmethod: none
user.privileged: root
user.unprivileged: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error connect disconnect
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error connect disconnect
}
EOF'

# Tạo nội dung cho tập tin /etc/systemd/system/sockd.service
sudo bash -c 'cat <<EOF > /etc/systemd/system/sockd.service
[Unit]
Description=Dante SOCKS Daemon
After=network.target

[Service]
ExecStart=/usr/local/sbin/sockd -N 2 -f /etc/sockd.conf

[Install]
WantedBy=multi-user.target
EOF'

# Bật dịch vụ Dante Proxy và khởi động lại systemd
sudo systemctl daemon-reload
sudo systemctl enable sockd
sudo systemctl start sockd

# Cài đặt và cấu hình FirewallD
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=46996/tcp --permanent
sudo firewall-cmd --reload
