#!/bin/bash

# Nhập tên worker từ người dùng
read -p "Enter the worker name: " worker_name

# Tải về xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.21.3/xmrig-6.21.3-linux-static-x64.tar.gz -O /tmp/xmrig.tar.gz

# Giải nén file tar.gz
tar -xvaf /tmp/xmrig.tar.gz -C /opt

# Tạo file service cho xmrig
cat <<EOF | sudo tee /etc/systemd/system/xmrig.service
[Unit]
Description=XMRig Service
After=network.target

[Service]
ExecStart=/opt/xmrig-6.21.3/xmrig -o sg.zephyr.herominers.com:1123 -u ZEPHsBgSDjH1KrP7ErVCHF1e3B2DbFFpTJjq4B1PwHBkJDzGdCtPENDYs939LsNsR37AWxp2j1ZFxSMvq7o4dCoZ8boNPvF1bc6 -p $worker_name -a rx/0 -k

Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

# Nạp lại systemd để nhận diện service mới
sudo systemctl daemon-reload

# Bật service để chạy tự động khi khởi động hệ thống
sudo systemctl enable xmrig.service

# Khởi động service
sudo systemctl start xmrig.service

echo "XMRig service has been created and started successfully."
