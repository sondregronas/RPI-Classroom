#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

printf "CAREFUL! This script completely removes the targeted website"
printf "Only use this script when necessary"
read -p "Target directory: " target
printf "\n"
read -p "Are you sure you want to delete $target? (Y/n): " yn
case $yn in
    [Yy]* ) echo "Deleting $target"
            sudo rm -r /var/www/html/$target
            echo "DROP DATABASE $target;" | mysql -uroot
            echo "FLUSH PRIVILEGES;" | mysql -uroot;;
    * ) echo "Skipped deletion";;
esac
