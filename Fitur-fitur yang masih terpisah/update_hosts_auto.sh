HOSTS_FILE="/etc/hosts"

    echo -n "Masukan IP server, contoh (192.168.100.101): "
    read server_ip

    echo -n "Masukan Domain Server, contoh (smofi.com): "
    read dns

    echo -n "Masukan Hostname, contoh (smofi): "
    read host

    # Baris yang akan diganti
    OLD_LINE="127.0.1.1    $dns    $host"

    # Baris baru
    NEW_LINE="$server_ip    $dns    $host"

    # Backup file /etc/hosts sebelum melakukan perubahan
    sudo cp $HOSTS_FILE "${HOSTS_FILE}.bak"

    # Gunakan sed untuk mengganti baris lama dengan baris baru
    sudo sed -i "/127.0.1.1.*$dns.*$host/c\\$NEW_LINE" $HOSTS_FILE

    echo "IP address has been updated in $HOSTS_FILE"
