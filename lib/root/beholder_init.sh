#!/bin/bash

# Test if is Root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "# Executing Beholder IoT install script"

# Update bootloader
apt update
apt full-upgrade
echo "FIRMWARE_RELEASE_STATUS=\"stable\"" > /etc/default/rpi-eeprom-update
rpi-eeprom-update -d -a
apt autoremove -y

# Install dependencies
echo "# Installing dependencies..."
apt-get update && apt-get dist-upgrade -y
curl -sSL https://get.docker.com | sh
usermod -aG docker pi
apt-get install -y \
    libffi-dev \
    libssl-dev \
    '^libssl1.0.[0-9]$' \
    libunwind8 \
    python3 \
    python3-pip \
    git \
    certbot \
    avahi-utils
apt-get remove -y python-configparser
pip3 -v install docker-compose
apt-get clean

# Get the os bits and set a variable
BITS=$(getconf LONG_BIT)

###################################
# Download and install ctop

if [ "$BITS" = "64" ]; then
    echo "# Downloading ctop arm64"
    curl -Lo /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/download/0.7.6/ctop-0.7.6-linux-arm64
fi

if [ "$BITS" = "32" ]; then
    echo "# Downloading ctop armhf"
    curl -Lo /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/download/0.7.6/ctop-0.7.6-linux-armhf
fi

chmod +x /usr/local/bin/ctop

###################################
# Download and extract PowerShell

echo "# Installing PowerShell..."

if [ "$BITS" = "64" ]; then
    # Grab the latest tar.gz
    wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/powershell-7.1.4-linux-arm64.tar.gz

    # Make folder to put powershell
    mkdir /usr/bin/powershell

    # Unpack the tar.gz file
    tar -xvf ./powershell-7.1.4-linux-arm64.tar.gz -C /usr/bin/powershell

    # Create a symlink for PowerShell
    ln -s /usr/bin/powershell/pwsh /usr/bin/pwsh

    # Remove the tar.gz file
    rm ./powershell-7.1.4-linux-arm64.tar.gz
fi

if [ "$BITS" = "32" ]; then
    # Grab the latest tar.gz
    wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/powershell-7.1.4-linux-arm32.tar.gz

    # Make folder to put powershell
    mkdir /usr/bin/powershell

    # Unpack the tar.gz file
    tar -xvf ./powershell-7.1.4-linux-arm32.tar.gz -C /usr/bin/powershell

    # Create a symlink for PowerShell
    ln -s /usr/bin/powershell/pwsh /usr/bin/pwsh

    # Remove the tar.gz file
    rm ./powershell-7.1.4-linux-arm32.tar.gz
fi

# Enable dwc2 on the Pi
if ! $(grep -q dtoverlay=dwc2 /boot/config.txt) ; then
    echo "dtoverlay=dwc2" | tee -a /boot/config.txt
fi

# Set a minimum memory split
if ! $(grep -q gpu_mem= /boot/config.txt) ; then
    echo "gpu_mem=16" | tee -a /boot/config.txt
fi

# Enable dwc2 initialization
if ! $(grep -q modules-load=dwc2 /boot/cmdline.txt) ; then
    echo "dwc2" | tee -a /etc/modules
fi

# Allow ctop to display container memory info
if ! $(grep -q "cgroup_enable=cpuset cgroup_enable=memory" /boot/cmdline.txt) ; then
    sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory/' /boot/cmdline.txt
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
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio,docker beholder
echo 'beholder:beholder' | chpasswd
echo 'beholder ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/010_beholder-nopasswd
usermod -L -s /bin/false -e 1 pi

# Enable Beholder Boot service
systemctl enable beholder_boot.service

# Remove the beholder install command
sed -i -e '/^\/etc\/beholder_init\.sh/d' /etc/rc.local
rm /etc/beholder_init.sh

# Reboot
reboot now