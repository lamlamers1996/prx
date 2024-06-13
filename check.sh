#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check a single proxy
check_proxy() {
    local proxy=$1
    local ip=$(echo $proxy | cut -d':' -f1)
    local port=$(echo $proxy | cut -d':' -f2)
    local user=$(echo $proxy | cut -d':' -f3)
    local pass=$(echo $proxy | cut -d':' -f4)

    # Use curl to check the proxy with a timeout of 2 seconds
    response=$(curl -s -o /dev/null -w "%{http_code}" --socks5 $ip:$port --proxy-user $user:$pass --max-time 2 http://checkip.amazonaws.com)

    if [ "$response" -eq 200 ]; then
        echo -e "Proxy $proxy ${GREEN}     hoạt động${NC}"
    else
        echo -e "Proxy $proxy ${RED}       Không hoạt động${NC}"
        failed_proxies+=("$proxy")
    fi
}

echo "Enter proxies (format ip:port:user:pass), one per line. End input with an empty line."

# Read proxies from user input
proxies=()
while true; do
    read -r proxy
    [ -z "$proxy" ] && break
    proxies+=("$proxy")
done

# Array to store failed proxies
failed_proxies=()

# Check each proxy
for proxy in "${proxies[@]}"; do
    check_proxy "$proxy"
done

# Output the failed proxies
if [ ${#failed_proxies[@]} -ne 0 ]; then
    echo "Danh sách proxy lỗi:"
    for failed_proxy in "${failed_proxies[@]}"; do
        echo "$failed_proxy"
    done
else
    echo "Tat Ca proxy hoạt động${NC}"
fi
