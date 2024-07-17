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

echo "Selesai menambahkan host."
