#!/bin/bash
echo "Welcome to the Wordpress One-click installer"
echo "This installer creates a subdirectory for Wordpress"

read -p "Type your desired html folder name: " input

target=$(echo "$input" | sed 's/\ /_/g')
host=$(hostname -I | cut -d' ' -f1)

# Make sure Raspbian is up to date, this part can be optional
apt-get update -y
apt-get upgrade -y

# Install necessary requirements
apt-get install apache2 -y
apt-get install php-gd -y

# These ones we should already have, keeping them here for now though
apt-get install php-mysql -y
apt-get install php -y
apt-get install mariadb-server -y

# Install WP-Cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html/
# This part is optional, it's responsible for creating subdirectories for additional websites per machine
mkdir $target
cd $target

wget http://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz

# This part runs through the secure installer, without setting a root password
# Disables remote access, does not set a root password. Basically yes to everything that isn't password related.
printf "\n n\n y\n y\n y\n y\n" | mysql_secure_installation

# Create a database & user with the X variable. Password is set to 'password', this is the default password for Wordpress
echo "create database $target;" | mysql -uroot
echo "CREATE USER '$target'@'localhost' IDENTIFIED BY 'password';" | mysql -uroot
echo "GRANT ALL ON $target.* TO '$target'@'localhost';" | mysql -uroot
echo "FLUSH PRIVILEGES;" | mysql -uroot


# Configuring wordpress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$target/g" wp-config.php
sed -i "s/username_here/$target/g" wp-config.php
sed -i "s/password_here/password/g" wp-config.php

# Default plugins and setup
# Sets up Wordpress, using the $target as admin username, password admin
# Creates a guest user, guest/guest
# This deletes every theme and plugin
# Then installs the theme 'Page Builder Framework'
# And the plugin(s): Elementor, Duplicator, Lazy Load
# Force Login, Remove Dashboard for non admins


wp core install --title="$target" \
                --url="$host/$target" \
                --admin_user="$target" \
                --admin_email="admin@127.0.0.1" \
                --admin_password="admin" \
                --path="/var/www/html/$target/" \
                --allow-root

wp user create guest --user_pass="guest" guest@127.0.0.1 \
                     --role="subscriber" --allow-root --path="/var/www/html/$target/"

wp plugin delete --all --allow-root --path="/var/www/html/$target/"
wp plugin install elementor --activate --allow-root --path="/var/www/html/$target/"
wp plugin install duplicator --activate --allow-root --path="/var/www/html/$target/"
wp plugin install wp-force-login --activate --allow-root --path="/var/www/html/$target/"
wp plugin install remove-dashboard-access-for-non-admins --activate --allow-root --path="/var/www/html/$target/"
wp theme install page-builder-framework --activate --allow-root --path="/var/www/html/$target/"
wp theme delete --all --allow-root --path="/var/www/html/$target/"

# Finishing touches
chown -R www-data: /var/www/html/.
service apache2 restart

###########
# TODO: Send a URL to the Admin Pi & update the adminpi/index.html
###########

printf "\n\n\n"
echo "- - - - - - - - - - - - - - - - - -"
echo "We're done! Your website is waiting for you."
echo "URL: http://$host/$target/wp-admin"
echo "Username: $target"
echo "Password: admin"
echo "Guests can login using guest/guest"
echo "- - - - - - - - - - - - - - - - - -"
