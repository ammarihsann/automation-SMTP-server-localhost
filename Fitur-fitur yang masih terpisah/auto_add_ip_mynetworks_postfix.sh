#!/bin/bash

#apt update
#apt install -y postfix dovecot-imapd dovecot-pop3d thunderbird

# Lokasi file konfigurasi Postfix
POSTFIX_MAIN_CF="/etc/postfix/main.cf"

# Baca IP baru dari input pengguna
echo -n "Masukan IP contoh (192.168.100.0/24): "
read ip

# Fungsi untuk menambahkan IP ke konfigurasi mynetworks
add_ip_to_mynetworks() {
    IP=$1
    # Cek apakah IP sudah ada di mynetworks
    if grep -q "mynetworks.*$IP" $POSTFIX_MAIN_CF; then
        echo "IP $IP sudah ada di konfigurasi mynetworks. Tidak ditambahkan."
    else
        # Tambahkan IP ke mynetworks
        awk -v new_ip="$IP" '/^mynetworks/ {print $0 ", " new_ip; next} 1' $POSTFIX_MAIN_CF > /tmp/main.cf
        mv /tmp/main.cf $POSTFIX_MAIN_CF
        echo "IP $IP ditambahkan ke konfigurasi mynetworks."
    fi
}

# Panggil fungsi untuk menambahkan IP
add_ip_to_mynetworks $ip

# Restart Postfix untuk menerapkan perubahan
systemctl restart postfix
