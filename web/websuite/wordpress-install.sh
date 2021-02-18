#!/bin/bash
echo Welcome to the Wordpress One-click installer
echo This installer creates a subdirectory for Wordpress

read -p "Type your desired html folder name: " X

# Make sure Raspbian is up to date, this part can be optional
apt-get update -y
apt-get upgrade -y

# Install necessary requirements
apt-get install apache2 -y

# These ones we should already have, keeping them here for now though
apt-get install php-mysql -y
apt-get install php -y
apt-get install mariadb-server -y

cd /var/www/html/

# This part is optional, it's responsible for creating subdirectories for additional websites per machine
mkdir $X
cd $X

wget http://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
chown -R www-data: .

# This part runs through the secure installer, without setting a root password
# Disables remote access, does not set a root password. Basically yes to everything that isn't password related.
printf "\n n\n y\n y\n y\n y\n" | sudo mysql_secure_installation

# Create a database & user with the X variable. Password is set to 'password', this is the default password for Wordpress
echo "create database $X;" | mysql -uroot
echo "CREATE USER '$X'@'localhost' IDENTIFIED BY 'password';" | mysql -uroot
echo "GRANT ALL ON $X.* TO '$X'@'localhost';" | mysql -uroot
echo "FLUSH PRIVILEGES;" | mysql -uroot

# Finishing touches
sudo service apache2 restart

###########
# TODO: Send a URL to the Admin Pi & update the adminpi/index.html
###########

printf "\n\n\n"
echo ----------------------------------
echo ----------------------------------
echo All done, use the Database and Username: $X,
echo when setting up your installation at $(hostname -I)/$X
echo Leave the password as password, and use localhost as the host
echo ----------------------------------
echo ----------------------------------
