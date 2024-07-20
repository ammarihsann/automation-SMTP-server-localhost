#!/bin/bash

# Fungsi untuk mengupdate entri di /etc/hosts
update_hosts() {
    # File /etc/hosts yang akan dimodifikasi
    HOSTS_FILE="/etc/hosts"
    echo -n "Masukan IP server, contoh (192.168.100.101): "
    read IP_server

    echo -n "Masukan Domain Server, contoh (smofi.com): "
    read dns

    echo -n "Masukan Hostname, contoh (smofi): "
    read host

    # Baris yang akan diganti
    OLD_LINE="127.0.1.1     $dns    $hostname"

    # Baris baru
    NEW_LINE="$IP_server    $dns    $host"

    # Backup file /etc/hosts sebelum melakukan perubahan
    sudo cp $HOSTS_FILE "${HOSTS_FILE}.bak"

    # Gunakan sed untuk mengganti baris lama dengan baris baru
    sudo sed -i "s|$OLD_LINE|$NEW_LINE|" $HOSTS_FILE

    echo "IP address has been updated in $HOSTS_FILE"
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

# Panggil fungsi untuk mengupdate /etc/hosts
update_hosts

# Instalasi Postfix, Dovecot, dan Thunderbird
sudo apt update
sudo apt install -y postfix dovecot-imapd dovecot-pop3d thunderbird apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Baca IP baru dari input pengguna
echo -n "Masukan IP contoh (192.168.100.0/24): "
read mynetworks_ip

# Panggil fungsi untuk menambahkan IP ke mynetworks
add_ip_to_mynetworks $mynetworks_ip

# Restart Postfix untuk menerapkan perubahan
sudo systemctl restart postfix

echo "Postfix, Dovecot, dan Thunderbird Apache2 telah diinstal dan dikonfigurasi."

# Install MariaDB Server
sudo apt-get install -y mariadb-server

echo -n "Input Password untuk user database: "
read -s pass
echo

# Create a new MariaDB user and grant privileges
sudo mysql -u root <<EOF
CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '$pass';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "MariaDB installation and user setup completed."

# Install Roundcube
sudo apt-get install -y roundcube

# Backup original config.inc.php
sudo cp /etc/roundcube/config.inc.php /etc/roundcube/config.inc.php.bak

# Update config.inc.php with the required configurations
sudo sed -i "s|\(\$config\['imap_host'\] = \).*|\1['$dns:143'];|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_host'\] = \).*|\1'$dns:25';|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_user'\] = \).*|\1'';|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_pass'\] = \).*|\1'';|" /etc/roundcube/config.inc.php

# Backup original apache.conf
sudo cp /etc/roundcube/apache.conf /etc/roundcube/apache.conf.bak

# Update apache.conf with the required configurations
sudo sed -i "s|#\s*Alias /roundcube /var/lib/roundcube/|Alias /roundcube /var/lib/roundcube/|" /etc/roundcube/apache.conf
sudo sed -i "s|<Directory /var/lib/roundcube/public_html/>|<Directory /var/lib/roundcube/>|" /etc/roundcube/apache.conf

# Backup original 000-default.conf
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak

# Update 000-default.conf with the required configurations
sudo sed -i "s|<VirtualHost \*:80>|<VirtualHost $server_ip:80>|" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|ServerAdmin webmaster@localhost|ServerAdmin webmaster@$dns|" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot /var/lib/roundcube/|" /etc/apache2/sites-available/000-default.conf

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Roundcube installation and configuration completed."
