# Beholder IoT Image Builder - RPi4

Automation to create an initial Beholder SD image for the Raspberry Pi 4.

## Hardware:
1. Obtain a Raspberry Pi 4, preferrebly one that is Revision 1.2, such as those found [here](https://www.canakit.com/official-raspberry-pi-4-desktop-kit.html?cid=usd&src=raspberrypi) or [here](https://www.amazon.com/Vilros-Raspberry-Complete-Transparent-Cooled/dp/B07VFCB192)
2. Obtain a Raspberry Pi USB Type C to USB-A cable, such as [this](https://www.amazon.com/gp/product/B07214QNQX/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1) or USB-C to USB-C
3. You'll need a SD card of at least 16GB - the more the better. With the advent of raspberry-pis being able to boot directly from SSD/USB, this can be an option too.

## Software:

- Docker
- NodeJS
- Yarn

## Building an image

The automated process will download the latest Raspberry Pi OS image and add the necessary bits to run Pi-Beholder

```
yarn install
yarn create-image
```

After answering the prompts, flash a SD/Equivalent with the image file located in ./images, Attach it to your Raspberry Pi 4 and let 'er rip.

The first boot process will take a bit of time as updates and dependencies will be installed. Once complete simply SSH into ``beholder@beholder-01.local`` with the default password of ```beholder```

> Note: If you've ssh'd into the Beholder before, use ```ssh-keygen -R beholder-01.local``` to clear the previous host key.

After the first boot the SD card can be cloned if desired.

See MANUAL.md for manual image building instructions.

For non-interactive image creation, add an .env file with the following variables:
 - WPA_SSID
 - WPA_PASSPHRASE
 - RPI_HOSTNAME
 - RPI_TIMEZONE