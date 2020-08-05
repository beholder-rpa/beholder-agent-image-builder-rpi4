#!/bin/bash

IMAGE_PATH=$(find /create/images/*.img -type f -print -quit)

if [ ! -e $IMAGE_PATH ]; then
  echo "No filesystem detected at ${IMAGE_PATH}!"
  exit 1
fi

echo "Using ${IMAGE_PATH}"

# Capture the patition details.
BOOT_PARTITION=`fdisk -l "${IMAGE_PATH}" | grep "c W95 FAT32 (LBA)"`
ROOT_PARTITION=`fdisk -l "${IMAGE_PATH}" | grep "83 Linux"`

# Grab the starting sector of the partitions.
BOOT_START_SECTOR=`echo "$BOOT_PARTITION" | awk '{print $2}'`
ROOT_START_SECTOR=`echo "$ROOT_PARTITION" | awk '{print $2}'`

# Calculate the start byte of the partitions.
((BOOT_START_BYTE=$BOOT_START_SECTOR * 512))
((ROOT_START_BYTE=$ROOT_START_SECTOR * 512))

# Grab the sector length of the partitions.
BOOT_SECTOR_LENGTH=`echo "$BOOT_PARTITION" | awk '{print $4}'`
ROOT_SECTOR_LENGTH=`echo "$ROOT_PARTITION" | awk '{print $4}'`

# Calculate the byte length of the partitions.
((BOOT_BYTE_LENGTH=$BOOT_SECTOR_LENGTH * 512))
((ROOT_BYTE_LENGTH=$ROOT_SECTOR_LENGTH * 512))

# Create the mount points.
mkdir -p /mnt/image/boot
mkdir -p /mnt/image/root

# Mount the partitions to the mount points.
mount -v -o offset=$BOOT_START_BYTE,sizelimit=$BOOT_BYTE_LENGTH -t vfat "${IMAGE_PATH}" /mnt/image/boot
mount -v -o offset=$ROOT_START_BYTE,sizelimit=$ROOT_BYTE_LENGTH -t ext4 "${IMAGE_PATH}" /mnt/image/root

./index.js

# Copy generated files on over to the boot image
cp ./lib/boot/wpa_supplicant.conf /mnt/image/boot
touch /mnt/image/boot/ssh

# Copy service files on over to the root image
mkdir -p /mnt/image/root/home/pi/beholder/
cp ./lib/root/* /mnt/image/root/home/pi/beholder/
cp ./lib/root/beholder_boot.sh /mnt/image/root/etc/
cp ./lib/root/hostname /mnt/image/root/etc/
cp ./lib/root/timezone /mnt/image/root/etc/

# Add the boot script
sed -i -e '$i \sudo /etc/beholder_boot.sh\n' /mnt/image/root/etc/rc.local

$@

# Unmount the partitions
umount /mnt/image/boot
umount /mnt/image/root
