#!/bin/bash

# Test if is Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "# Executing Beholder IoT install script"

# Update bootloader
apt update
apt full-upgrade
echo "FIRMWARE_RELEASE_STATUS=\"stable\"" > /etc/default/rpi-eeprom-update
rpi-eeprom-update -d -a

# Install dependencies
if [ ! -d "/home/pi/beholder" ] 
then
    apt-get update && sudo apt-get dist-upgrade -y
    curl -sSL https://get.docker.com | sh
    usermod -aG docker pi
    apt-get install -y git libffi-dev libssl-dev python3 python3-pip
    apt-get remove -y python-configparser
    pip3 -v install docker-compose
    git clone https://github.com/beholder-rpa/beholder-iot /home/beholder/beholder
fi

# Enable dwc2 on the Pi
if ! $(grep -q dtoverlay=dwc2 /boot/config.txt) ; then
    echo "dtoverlay=dwc2" | tee -a /boot/config.txt
fi

# Enable dwc2 initialization
if ! $(grep -q modules-load=dwc2 /boot/cmdline.txt) ; then
    echo "dwc2" | tee -a /etc/modules
fi

# Add libcomposite to modules
if ! $(grep -q libcomposite /etc/modules) ; then
    echo "libcomposite" | tee -a /etc/modules
fi

# Don't obtain a DHCP address for usb0
if ! $(grep -q "denyinterfaces usb0" /etc/dhcpcd.conf) ; then
    echo "denyinterfaces usb0" | tee -a /etc/dhcpcd.conf
fi

# ensure dnsmasq has been installed
if [[ ! -e /usr/sbin/dnsmasq ]] ; then
    apt-get install -y dnsmasq
fi

# Add the address range for the USB
if [[ ! -e /etc/dnsmasq.d/usb ]] ; then
    mkdir -p /etc/netmasq.d/
    tee -a /etc/dnsmasq.d/usb << EOF 
interface=usb0
dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
dhcp-option=3
leasefile-ro
EOF
    echo "Created /etc/dnsmasq.d/usb"
fi

if [[ ! -e /etc/network/interfaces.d/usb0 ]] ; then
    tee -a /etc/network/interfaces.d/usb0 << EOF
auto usb0
allow-hotplug usb0
iface usb0 inet static
  address 10.55.0.1
  netmask 255.255.255.248
EOF
    echo "Created /etc/network/interfaces.d/usb0"
fi

# Set the timezone 
tz=$(cat /etc/timezone)
timedatectl set-timezone $tz

# Create a beholder user and lock the built-in pi user

adduser --gecos "" beholder
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio beholder
echo 'beholder:beholder' | chpasswd
echo 'beholder ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/010_beholder-nopasswd
usermod -L -s /bin/false -e 1 pi

# Enable HID service
cp /home/beholder/beholder/beholder-otg/beholder_otg.service /etc/systemd/system/
chmod 644 /etc/systemd/system/beholder_otg.service
chmod +x /home/beholder/beholder/beholder-otg/beholder_otg.sh
systemctl enable beholder_otg.service

# Enable Beholder docker service
cp /home/beholder/beholder/beholder-otg/beholder_docker.service /etc/systemd/system/
chmod 644 /etc/systemd/system/beholder_docker.service
chmod +x /home/beholder/beholder/beholder-otg/beholder_docker.sh
systemctl enable beholder_docker.service

# Remove the beholder boot command
sed -i -e '/^\/etc\/beholder_boot\.sh/d' /etc/rc.local
rm /etc/beholder_boot.sh

# Reboot
reboot now