#!/bin/bash

# Test if is Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "# Executing Beholder IoT boot script..."

if [ -f "/home/beholder/.init" ] 
then
    # Run one-time initialization

    # Initialize services
    systemctl enable beholder_otg.service

    # Run user initialization

    sudo -u beholder /home/beholder/.init
    rm /home/beholder/.init

    echo "# Completed initial run of the Beholder IoT boot script - rebooting..."
    reboot now
else
    # Run User land boot script
    sudo -u beholder /home/beholder/.boot

    # Ensure any changes to the HID service are copied over
    echo "# Updating Beholder OTG."
    cp /home/beholder/beholder/beholder-otg/beholder_otg.service /etc/systemd/system/
    cp /home/beholder/beholder/beholder-otg/beholder_otg.sh /usr/bin/
    chmod 644 /etc/systemd/system/beholder_otg.service
    chmod +x /usr/bin/beholder_otg.sh

    echo "# Beholder OTG updated."
fi

echo "# Completed Beholder IoT boot script."