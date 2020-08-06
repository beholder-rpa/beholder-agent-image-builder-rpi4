#!/bin/bash

# Test if is Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "# Executing Beholder IoT boot script..."

# Ensures that on each boot, the otg/docker scripts are up to date.
if [ ! -d "/home/beholder/beholder" ] 
then
    git clone https://github.com/beholder-rpa/beholder-iot /home/beholder/beholder
fi

if [ -d "/home/beholder/beholder/" ]
then
    # Enable HID service
    cp /home/beholder/beholder/beholder-otg/beholder_otg.service /etc/systemd/system/
    cp /home/beholder/beholder/beholder-otg/beholder_otg.sh /usr/bin/
    chmod 644 /etc/systemd/system/beholder_otg.service
    chmod +x /usr/bin/beholder_otg.sh
    systemctl enable beholder_otg.service

    # Enable Beholder docker service
    cp /home/beholder/beholder/beholder-otg/beholder_docker.service /etc/systemd/system/
    cp /home/beholder/beholder/beholder-otg/beholder_docker.sh /usr/bin/
    chmod 644 /etc/systemd/system/beholder_docker.service
    chmod +x /usr/bin/beholder_docker.sh
    systemctl enable beholder_docker.service
fi

echo "# Completed Beholder IoT boot script."