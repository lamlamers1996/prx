#!/bin/bash

# Lấy địa chỉ IPv4 công khai của máy chủ từ ifconfig.me
ipv4_address=$(curl -s http://ifconfig.me)

# Kiểm tra nếu có địa chỉ IPv4
if [ -n "$ipv4_address" ]; then
    # Xóa tệp secrets.txt cũ
    sudo rm -f /root/secrets.txt

    # Tạo chuỗi ngẫu nhiên
    random_str=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

    # Tạo tệp secrets.txt mới với nội dung cần thiết
    echo -e "phambang $random_str" | sudo tee /root/secrets.txt >/dev/null

    # Khởi động lại dịch vụ và kiểm tra trạng thái
    sudo systemctl restart gost.service

    # Trả về chuỗi ngẫu nhiên dưới dạng ip máy chủ:6789:phambang:$random_str
    echo "$ipv4_address:6789:phambang:$random_str"
else
    echo "Không tìm thấy địa chỉ IPv4 cho máy chủ."
fi
