#!/bin/bash

# Test if is Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "# Executing Beholder IoT boot script..."

export IS_NEW="false"

# Ensures that on each boot, the otg/docker scripts are up to date.
if [ ! -d "/home/beholder/beholder" ] 
then
    git clone --depth=1 https://github.com/beholder-rpa/beholder-iot /home/beholder/beholder
    chown -hR beholder:beholder /home/beholder/beholder
    export IS_NEW="true"
fi

if [ -d "/home/beholder/beholder/" ]
then
    # Enable HID service
    echo "# Updating Beholder OTG."
    cp /home/beholder/beholder/beholder-otg/beholder_otg.service /etc/systemd/system/
    cp /home/beholder/beholder/beholder-otg/beholder_otg.sh /usr/bin/
    chmod 644 /etc/systemd/system/beholder_otg.service
    chmod +x /usr/bin/beholder_otg.sh

    echo "# Beholder OTG updated."

    # Enable Beholder docker service
    echo "# Updating Beholder Docker."
    cp /home/beholder/beholder/beholder-otg/beholder_docker.service /etc/systemd/system/
    cp /home/beholder/beholder/beholder-otg/beholder_docker.sh /usr/bin/
    chmod 644 /etc/systemd/system/beholder_docker.service
    chmod +x /usr/bin/beholder_docker.sh
    
    echo "# Beholder Docker updated."
fi

if [ "$IS_NEW" = "true" ]
then
    systemctl enable beholder_otg.service
    systemctl enable beholder_docker.service
    echo "# Completed initial run of the Beholder IoT boot script - rebooting..."
    reboot now
fi

echo "# Completed Beholder IoT boot script."