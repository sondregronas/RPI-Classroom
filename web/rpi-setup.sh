#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "Welcome to the Raspberry Pi Classroom setup"
echo "The following script will do the following:"
echo "- Enable SSH on the default port (22)"
echo "- Disable AutoLogin to Pi"
echo "- Change the password of Pi"
echo "- Allows you to change the hostname"
echo "- Create users for your classroom, and add them to sudoers (And remove root access for said users)"
echo "To top it all of, the system is also updated & rebooted."
echo "- - -"

printf "\nIt's time to set an admin password for the 'pi' user.\n"
while true; do
    read -s -p "Password: " password
    printf "\n"
    read -s -p "Password (again): " password2
    [ "$password" = "$password2" ] && printf "$password\n$password\n" | passwd pi && break
    printf "\nPlease try again"
done

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

echo "It's time to create some local users. Note, all users will be added to the sudo group"
echo "The default password is 123."
while true; do
    printf "\n"
    read -p "Add new user? (Y/n): " yn
    case $yn in
        [Nn]* ) break;;
        [Yy]* )
        read -p "\nUsername: " uname
        printf "123\n123\n\n\n\n\n\n\n" | adduser $uname
        usermod -aG sudo $uname
        ###########
        # TODO: DISABLE sudo -i access or sudo su
        ###########
        printf "\nSuccessfully added $uname.\n"
        continue;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Changing the hostname"
while true; do
  read -p "Name this machine: " host_name
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

printf "\nThank you! The script will handle the rest. Good luck!"

sleep 2

apt-get update -y
apt-get upgrade -y

###########
# TODO: Add more useful packages/tools here, it'll save us time later
###########

apt-get install php-mysql php mariadb-server -y

reboot
