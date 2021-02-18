# RPI-Classroom
This is a project I'll hopefully be working on, with the intent of lowering the bar for certain applications.

For now it's mostly for lazy and hacky workarounds.

The intent for the current scripts is to be used when you first setup the pi, and to create a website for the administator/teacher's pi housing various scripts.

Currently there is only a script to automate the process of setting up a Wordpress Site (no pre-reqs), an example is shown in the index.html file.
The site will be accessible using the students pi's ip-address, in the directory of his pi-user, i.e. 192.168.10.22/username

There's also a script (rpi-setup.sh) which is just a lazy way of creating users for every student (Password is defaulted to 123), aswell as making sure SSH is enabled,
setting an admin password, disabling autologin, changing the hostname and eventually removing root access via sudo su or sudo -i. 
It also updates the pi and pre-installs some packages to save time later.

# Example usage
On the admin/teacher's pi:
```
sudo git clone https://github.com/sondregronas/RPI-Classroom && \
cd RPI-Classroom && \
sudo chmod +x adminsetup.sh && \
sudo ./adminsetup.sh
```

On the student pi's, preferrably via SSH, (eventually via the adminsetup using CLI-options)<br>
`sudo wget ip.of.admin.pi/rpi-setup.sh && sudo chmod +x rpi-setup.sh && sudo ./rpi-setup.sh`

More instructions will eventually be found at `http://*ip.of.admin.pi*/`

# Disclaimer
This is for a closed network, opening up for external access is not recommended, the scripts leave a lot of passwords empty or at '123' by default.
