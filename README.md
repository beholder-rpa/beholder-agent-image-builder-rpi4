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

After answering the prompts, flash a SD with the image file located in ./images, Attach it to your Raspberry Pi 4 and let 'er rip.

The first boot process will take a bit of time as updates and dependencies will be installed. Once complete simply SSH into ``beholder@beholder-01.local`` with the default password of ```beholder```

> Note: If you've ssh'd into the Beholder before, use ```ssh-keygen -R beholder-01.local``` to clear the previous host key.

After the first boot the SD card can be cloned if desired.

See MANUAL.md for manual image building instructions.

# Beholder MSD

This automated install includes the updated firmware necessary to boot from a USB Mass Storage Device, however, it may require that the bootloader be updated to the stable channel prior to first boot from a USB MSD. If flashed to a SD card, the image will take care of this allowing the next boot to be from a MSD.

See https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md#usbmassstorageboot for more details.

[This USB 3.1 Flash Drive](https://www.amazon.com/gp/product/B07D7PDLXC/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1) is super convenient and gives about 1/2 the performance of a state-of-the-art SSD w/usb adapter. Making it faster than any SD card out there, but trading off sheer speed for the convience of connecting directly to the RPi without additional bulk

See https://storage.jamesachambers.com/benchmark/30186

## Automated Image Creation

For non-interactive image creation, add an .env file with the following variables, or set these environment variables manually.

 - WPA_SSID
 - WPA_PASSPHRASE
 - RPI_HOSTNAME
 - RPI_TIMEZONE