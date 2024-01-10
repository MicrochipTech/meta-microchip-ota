#!/bin/sh

# init script to boot main app image or run upgrade/recovery operations from initramfs

ROOT_MOUNT=""
CMDLINE=""
INSTALL_FW=""

# exec sh here is for debug and not a secure solution
# as shell access should not be allowed in the initramfs
fail() {
    echo $1 >$CONSOLE
    echo >$CONSOLE
    exec sh
}

# do initial setup
init_system() {
    mkdir -p /proc /sys /run /var/run
    mount -t proc proc /proc
    mount -t sysfs sysfs /sys
    mount -t devtmpfs none /dev

    mdev -s

    CMDLINE=`cat /proc/cmdline`

    # get active boot parition
    ROOTPART=`fw_printenv | sed -n 's/\brootpart=//p'`
}

boot_main_image() {
    echo ""
    echo "/*****************************************************************************/"
    echo "/********************* Booting main image from mmcblk0p$ROOTPART *********************/"
    echo "/*****************************************************************************/"
    echo ""
    
     # prepare to switch_root to actual filesystem
    mount -o move /boot ${ROOT_MOUNT}/boot || fail "Error, dropping to shell"
    mount -o move /proc ${ROOT_MOUNT}/proc || fail "Error, dropping to shell"
    mount -o move /sys ${ROOT_MOUNT}/sys || fail "Error, dropping to shell"
    mount -o move /dev ${ROOT_MOUNT}/dev || fail "Error, dropping to shell"

    cd $ROOT_MOUNT

    exec switch_root -c /dev/console $ROOT_MOUNT /sbin/init $CMDLINE || fatal "Couldn't switch_root, dropping to shell"
}

boot_initramfs() {
    echo ""
    echo "/*****************************************************************************/"
    echo "/****************** Booting initramfs for firmware install *******************/"
    echo "/*****************************************************************************/"
    echo ""
    exec /sbin/init
}

# main entry point
init_system

# if ROOTPART is empty, set default partition to 2
if [ -z "$ROOTPART" ]
then
    echo "Default partition not set, setting to 2"
    ROOTPART=2
fi

ROOT_MOUNT="/run/media/mmcblk0p$ROOTPART"
INSTALL_FW=`fw_printenv | sed -n 's/\bupgrade_available=//p'`

if [ -z "$INSTALL_FW" ] || [ "$INSTALL_FW" -eq "0" ]
then
    # if upgrade_available env is not present or 0 boot main image
    boot_main_image
else
    # boot initramfs to handle firmware install or recovery operations
    boot_initramfs
fi
