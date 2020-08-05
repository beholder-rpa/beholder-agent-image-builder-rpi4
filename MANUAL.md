For manual installs of the required software, perform the following steps

Run Hand/Nexus/Cerebrum/Cortex on a RPi4 using these directions:

> Note: Eye and Telekinesis must always run on the host.

## Raspberry Pi OS Image and Configuration
1. Download [Raspberry Pi OS Lite](https://www.raspberrypi.org/downloads/raspbian/) image (Buster of this writing)
2. Edit the .img file. On macOS, mount the .img and add/edit the files, on Windows, mount the image in WSL2 and add/edit the files.
    1. Add a file named ```wpa_supplicant.conf``` at the root to auto-connect to wifi that contains the following:

        ```
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1
        country=US
        network={
            ssid="${WPA_SSID}"
            psk="${WPA_PSK}"
            key_mgmt=WPA-PSK
        }
        ```

    2. Add an empty file named ```ssh``` at the root to enable ssh
    3. (TBD) Should be possible to create a service in the .img that configures the hostname, default password, timezone, software installation on first boot and then removes itself.
3. Use [Etcher](https://www.balena.io/etcher/) to write the image to a SD Card

## Raspberry Pi Firmware
1. Boot the Raspberry Pi and SSH into ``pi@raspberrypi.local``
    > Note: If you've ssh'd into a raspberrypi before, use ```ssh-keygen -R raspberrypi.local``` first.
2. Ensure the latest RPi 4 Firmware using
```
sudo apt update
sudo apt full-upgrade
sudo nano /etc/default/rpi-eeprom-update
```

Change the FIRMWARE_RELEASE_STATUS value from "critical" to "stable" and save

Installer the new bootloader by running

```
sudo rpi-eeprom-update -d -a
sudo reboot now
```

When it comes back up, re-ssh into the device and run

```
vcgetncmd bootloader_version
```

to ensure the latest firmware date.

## Raspberry Pi Beholder Initial Setup

1. Configure The Rasberry Pi
    1. ```sudo raspi-config```
    2. Set Hostname to ```beholder-01```
    3. Set a default password
    4. Set the timezone
    5. Set the memory split to 16mb
    6. Save, Reboot
2. Now SSH into ``pi@beholder-01.local``
3. Install Software

    1. ```sudo apt-get update && sudo apt-get dist-upgrade -y && sudo reboot now```
    2. ```curl -sSL https://get.docker.com | sh```
    3. ```sudo usermod -aG docker pi```
    4. ```sudo apt-get install -y git python python-pip libffi-dev python-backports.ssl-match-hostname```
    5. ```sudo pip install docker-compose```
    5. ```git clone https://github.com/oceanswave/beholder2 beholder```
    6. ```cd beholder/beholder-rpi4/```
    7. ```sudo ./rpi4-setup/setup.sh```


## Resources:
https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/