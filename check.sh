#!/bin/bash

# Kiểm tra xem người dùng đã cung cấp đường dẫn đến tệp proxy.txt chưa
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/proxy.txt"
    exit 1
fi

# Đường dẫn đến tệp proxy
proxy_file=$1

# Cấu hình proxy (có thể thay đổi tùy thuộc vào cấu hình của bạn)
port=6789
user="admin"  # Thay bằng username của bạn
pass="adminbang123"  # Thay bằng password của bạn

# Kiểm tra từng proxy trong tệp
while IFS= read -r proxy; do
    # Sử dụng curl để kiểm tra proxy
    response=$(curl --socks5 "$user:$pass@$proxy:$port" -s -o /dev/null -w "%{http_code}" http://www.google.com)

    if [ "$response" -eq 200 ]; then
        echo "Proxy $proxy:$port is working."
    else
        echo "Proxy $proxy:$port is not working."
    fi
done < "$proxy_file"
