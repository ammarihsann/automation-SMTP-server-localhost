# Backup original 000-default.conf
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak

# Update 000-default.conf with the required configurations
sudo sed -i "s|<VirtualHost \*:80>|<VirtualHost 192.168.100.81:80>|" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|ServerAdmin webmaster@localhost|ServerAdmin webmaster@debian.smofi|" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot /var/lib/roundcube/|" /etc/apache2/sites-available/000-default.conf

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Roundcube installation and configuration completed."
