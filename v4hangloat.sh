#!/bin/bash

# Kiểm tra xem sshpass có được cài đặt chưa
if ! command -v sshpass &> /dev/null
then
    echo "sshpass không được cài đặt. Bạn có thể cài đặt nó bằng cách chạy: sudo apt-get install sshpass"
    exit 1
fi

# Hàm để nhập thông tin máy chủ từ người dùng
function get_server_info() {
    local server_info
    echo "Nhập thông tin máy chủ theo định dạng ip|user|pass (hoặc nhập 'done' để kết thúc):"
    
    while true; do
        read -p "Nhập thông tin máy chủ: " server_info
        if [ "$server_info" == "done" ]; then
            break
        fi
        
        # Tách thông tin IP, user và pass
        IFS="|" read -r ip user pass <<< "$server_info"
        
        if [[ -z "$ip" || -z "$user" || -z "$pass" ]]; then
            echo "Thông tin không hợp lệ. Vui lòng nhập theo định dạng ip|user|pass."
            continue
        fi

        echo "Đang kết nối đến $ip với người dùng $user..."

        # Tạo file script nội dung bạn muốn chạy trên máy chủ từ xa
        SSH_SCRIPT=$(mktemp)
        cat <<EOF > $SSH_SCRIPT
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

echo "Hoàn tất cài đặt và cấu hình Squid."


EOF

        # Đảm bảo script trên máy chủ từ xa có quyền thực thi
        chmod +x $SSH_SCRIPT

        # Thực thi script trên máy chủ từ xa qua SSH
        sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user@$ip" 'bash -s' < $SSH_SCRIPT

        if [ $? -eq 0 ]; then
            echo "Kết nối và thực thi thành công trên máy chủ $ip"
        else
            echo "Kết nối hoặc thực thi thất bại trên máy chủ $ip"
        fi

        # Xóa file script tạm
        rm $SSH_SCRIPT

    done
}

# Gọi hàm để nhập thông tin máy chủ
get_server_info
