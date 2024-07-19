#!/bin/bash

# Update package lists
sudo apt-get update

# Install MariaDB Server
sudo apt-get install -y mariadb-server

# Create a new MariaDB user and grant privileges
sudo mysql -u root <<EOF
CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "MariaDB installation and user setup completed."
