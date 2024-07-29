#!/bin/bash

# Cập nhật danh sách gói
echo "Cập nhật danh sách gói..."
sudo apt update

# Cài đặt Squid
echo "Cài đặt Squid..."
sudo apt install -y squid

# Sao lưu file cấu hình mặc định
echo "Sao lưu file cấu hình mặc định..."
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Cấu hình Squid
echo "Cấu hình Squid..."
sudo bash -c 'cat <<EOL > /etc/squid/squid.conf
http_port 46996
acl all src all
http_access allow all
EOL'

# Khởi động lại dịch vụ Squid
echo "Khởi động lại dịch vụ Squid..."
sudo systemctl restart squid

# Kích hoạt Squid để khởi động cùng hệ thống
echo "Kích hoạt Squid để khởi động cùng hệ thống..."
sudo systemctl enable squid

ufw allow 46996
# Kiểm tra trạng thái dịch vụ Squid
echo "Kiểm tra trạng thái dịch vụ Squid..."
sudo systemctl status squid

echo "Hoàn tất cài đặt và cấu hình Squid."
