#!/bin/bash

# Update package lists
sudo apt-get update

# Install Roundcube
sudo apt-get install -y roundcube

# Backup original config.inc.php
sudo cp /etc/roundcube/config.inc.php /etc/roundcube/config.inc.php.bak

# Update config.inc.php with the required configurations
sudo sed -i "s|\(\$config\['imap_host'\] = \).*|\1['debian.smofi:143'];|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_host'\] = \).*|\1'debian.smofi:25';|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_user'\] = \).*|\1'';|" /etc/roundcube/config.inc.php
sudo sed -i "s|\(\$config\['smtp_pass'\] = \).*|\1'';|" /etc/roundcube/config.inc.php

echo "Roundcube installation and configuration completed."
