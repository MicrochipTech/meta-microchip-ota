#! /bin/sh

mv /opt/egt-swupdate.squashfs /tmp/
mv /opt/app_data.img /tmp/

# erase mdt0 for use as a JFFS2 partition to store swupdate cert
flash_erase -j /dev/mtd0 0 0

# copy the squashfs image containing the egt-swupdate app to mtd1 and 2
# and then delete the image
flashcp /tmp/egt-swupdate.squashfs /dev/mtd1

sync

mkdir /tmp/A
mkdir /tmp/B
mount /dev/mmcblk0p5 /tmp/A
mount /dev/mmcblk0p6 /tmp/B

cp /tmp/app_data.img /tmp/A
cp /tmp/app_data.img /tmp/B

sync
umount /tmp/A /tmp/B
