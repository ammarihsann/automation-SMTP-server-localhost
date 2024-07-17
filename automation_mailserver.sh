#!/bin/bash

# Fungsi untuk menambahkan host ke /etc/hosts
add_host() {
    HOST_ENTRY=$1
    # Tambahkan entri baru ke /etc/hosts jika belum ada
    if grep -q "$HOST_ENTRY" /etc/hosts; then
        echo "Host $HOST_ENTRY sudah ada di /etc/hosts. Tidak ditambahkan."
    else
        echo "$HOST_ENTRY" | sudo tee -a /etc/hosts > /dev/null
        echo "Host $HOST_ENTRY berhasil ditambahkan."
    fi
}

# Fungsi untuk menambahkan IP ke konfigurasi mynetworks
add_ip_to_mynetworks() {
    IP=$1
    POSTFIX_MAIN_CF="/etc/postfix/main.cf"
    # Cek apakah IP sudah ada di mynetworks
    if grep -q "mynetworks.*$IP" $POSTFIX_MAIN_CF; then
        echo "IP $IP sudah ada di konfigurasi mynetworks. Tidak ditambahkan."
    else
        # Tambahkan IP ke mynetworks
        awk -v new_ip="$IP" '/^mynetworks/ {print $0 ", " new_ip; next} 1' $POSTFIX_MAIN_CF > /tmp/main.cf
        sudo mv /tmp/main.cf $POSTFIX_MAIN_CF
        echo "IP $IP ditambahkan ke konfigurasi mynetworks."
    fi
}

# Proses penambahan host
while true; do
    # Baca input dari pengguna
    echo -n "Tambahkan IP host contoh (192.168.100.212 smofi.com smofi): "
    read host

    # Panggil fungsi untuk menambahkan host
    add_host "$host"

    # Tanyakan apakah ingin menambah host lagi
    echo -n "Apakah ingin menambah host lagi? (y/n): "
    read answer
    if [ "$answer" != "y" ]; then
        break
    fi
done

# Instalasi Postfix, Dovecot, dan Thunderbird
sudo apt update
sudo apt install -y postfix dovecot-imapd dovecot-pop3d thunderbird

# Baca IP baru dari input pengguna
echo -n "Masukan IP contoh (192.168.100.0/24): "
read ip

# Panggil fungsi untuk menambahkan IP ke mynetworks
add_ip_to_mynetworks $ip

# Restart Postfix untuk menerapkan perubahan
sudo systemctl restart postfix

echo "Selesai menambahkan host dan mengkonfigurasi Postfix."
