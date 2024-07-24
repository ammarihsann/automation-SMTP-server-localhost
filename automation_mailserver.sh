#!/bin/bash

# Fungsi untuk instalasi Postfix, Dovecot, Thunderbird, dan Apache2
install_mail_server() {
    sudo apt update
    sudo apt install -y postfix dovecot-imapd dovecot-pop3d thunderbird apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "Postfix, Dovecot, dan Apache2 telah diinstal."
}

# Fungsi untuk menambahkan IP ke konfigurasi mynetworks
add_ip_to_mynetworks() {
    local IP=$1
    local dns=$2
    local POSTFIX_MAIN_CF="/etc/postfix/main.cf"
    sudo sed -i "s|^\(myhostname = \).*|\1$dns|" /etc/postfix/main.cf
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

# Fungsi untuk instalasi dan konfigurasi MariaDB
install_mariadb() {
    sudo apt-get install -y mariadb-server
    echo -n "Input Password untuk user database: "
    read pass

    # Create a new MariaDB user and grant privileges
    sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'roundcube'@'localhost' IDENTIFIED BY '$pass';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost';
FLUSH PRIVILEGES;
EOF
    echo "MariaDB installation and user setup completed."
}

# Fungsi untuk instalasi dan konfigurasi Roundcube
install_roundcube() {
    local server_ip=$1
    local dns=$2

    sudo apt-get install -y roundcube

    # Backup original config.inc.php
    sudo cp /etc/roundcube/config.inc.php /etc/roundcube/config.inc.php.bak

    # Update config.inc.php with the required configurations
    sudo tee -i "s|\(\$config\['smtp_server'\] = \).*|\1['$dns'];|" /etc/roundcube/config.inc.ph
    sudo tee -i "s|\(\$config\['imap_host'\] = \).*|\1['$dns:143'];|" /etc/roundcube/config.inc.php
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
}

# Fungsi untuk instalasi dan konfigurasi BIND9
install_bind9() {
    sudo apt-get install -y bind9 bind9utils bind9-doc

    # Backup original named.conf.local
    sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak

    # Menambahkan zona untuk domain
    cat <<EOF | sudo tee -a /etc/bind/named.conf.local
zone "$dns" {
    type master;
    file "/etc/bind/db.$dns";
};
EOF

    # Membuat file zona untuk domain
    cat <<EOF | sudo tee /etc/bind/db.$dns
;
; BIND data file for $dns
;
\$TTL    604800
@       IN      SOA     ns1.$dns. admin.$dns. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.$dns.
ns     IN      A       $server_ip
@      IN      A        $server_ip
mail    IN    A        $server_ip
@       IN      A       $server_ip

EOF

    # Menambahkan konfigurasi nama server di resolv.conf
    echo "nameserver $server_ip" | sudo tee /etc/resolv.conf

    # Restart BIND9 untuk menerapkan perubahan
    sudo systemctl restart bind9

    echo "BIND9 installation and configuration completed."
}

# Proses utama
main() {
    echo -n "Masukan IP server, contoh (192.168.100.101): "
    read server_ip

    echo -n "Masukan Domain Server, contoh (smofi.com): "
    read dns

    echo -n "Masukan Hostname, contoh (smofi): "
    read host

    # Install Postfix, Dovecot, Thunderbird, and Apache2
    install_mail_server

    # Baca IP baru dari input pengguna
    echo -n "Masukan IP contoh (192.168.100.0/24): "
    read mynetworks_ip

    # Tambahkan IP ke konfigurasi mynetworks
    add_ip_to_mynetworks $mynetworks_ip

    # Restart Postfix untuk menerapkan perubahan
    sudo systemctl restart postfix

    # Install dan konfigurasi MariaDB
    install_mariadb

    # Install dan konfigurasi Roundcube
    install_roundcube $server_ip $dns

    # Install dan konfigurasi BIND9
    install_bind9
}

# Jalankan proses utama
main
