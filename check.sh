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

# Danh sách proxy lỗi
declare -a failed_proxies

# Kiểm tra từng proxy trong tệp
while IFS= read -r proxy; do
    # Sử dụng curl để kiểm tra proxy
    response=$(curl --socks5 "$user:$pass@$proxy:$port" --max-time 10 -s -o /dev/null -w "%{http_code}" http://www.google.com)

    if [ "$response" -eq 200 ]; then
        echo "Proxy $proxy:$port hoạt động"
    else
        echo "Proxy $proxy:$port proxy Không Hoạt Động"
        failed_proxies+=("$proxy:$port")
    fi
done < "$proxy_file"

# In ra các proxy lỗi
if [ ${#failed_proxies[@]} -ne 0 ]; then
    echo "danh sách proxy proxy Không Hoạt Động:"
    for proxy in "${failed_proxies[@]}"; do
        echo "$proxy"
    done
else
    echo "tất cả proxy hoạt động"
fi
