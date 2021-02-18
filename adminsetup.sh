#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "First the boring stuff, then the script does the rest."

echo "\nIt's time to set an admin password for the 'pi' user.\n"
while true; do
    read -s -p "Password: " password
    printf "\n"
    read -s -p "Password (again): " password2
    [ "$password" = "$password2" ] && printf "$password\n$password\n" | passwd pi && break
    printf "\nPlease try again"
done

echo "You might also want to change the hostname"
while true; do
  read -p "Name this machine: " host_name
  printf "\n"
  read -p "Are you happy with $host_name? (Y/n): " yn
  case $yn in
      [Nn]* ) continue;;
      [Yy]* )
      echo $host_name | sudo tee /etc/hostname
      sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"$host_name"'/' /etc/hosts
      sudo hostnamectl set-hostname $host_name
      break;;
  esac
done

###########
# Other queries can be added here, and used later
###########

echo "Boring stuff done, performing updates and various other tasks"

sleep 2

apt-get update -y
apt-get upgrade -y
echo "Update's done!"

echo "Enabling SSH"
systemctl enable ssh
systemctl start ssh

echo "Disabling Autologin"
sudo sed -i 's/^greeter-hide-users=true/greeter-hide-users=false/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^\#greeter-allow-guest=true/greeter-allow-guest=false/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^\#greeter-show-manual-login=false/greeter-show-manual-login=true/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^\#allow-guest=true/allow-guest=false/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^\#allow-guest=true/allow-guest=false/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^\#autologin-user-timeout=0/autologin-user-timeout=10/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/^autologin-user=pi/\#autologin-user=pi/g' /etc/lightdm/lightdm.conf

###########
# TODO: Add a -clients -users option, which runs RPI-Setup.sh automatically and distributes the users among the clients, if already configured with an ip & ssh enabled
###########
apt install apache2 -y

echo "Installing apache and moving the websuite"
rm /var/www/html/index.html
cp -a web/. /var/www/html/


echo "We're done here! Time for a quick reboot. Good luck!"
sleep 2
reboot
