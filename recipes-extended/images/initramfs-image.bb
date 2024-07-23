SUMMARY = "initramfs image"

LICENSE = "MIT"

IMAGE_INSTALL:append = " \
        packagegroup-core-boot \
        libubootenv-bin \
        net-tools \
        ifupdown \
        openssl \
        openssl-engines \
        initramfs-boot \
        cryptoauthlib \
        p11-kit \
        zchunk \
        swupdate \
        swupdate-progress \
        swupdate-tools-ipc \
        wpa-supplicant \
        mchp-wireless-firmware \
        wireless-regdb-static \
        kernel-modules \
        config-board \
        psplash \
        lua \
        curl \
        ifplugd \
        ntp \
        resolvconf \
"

IMAGE_INSTALL:remove = " \
        avahi-daemon \
        avahi-utils \
"

#IMAGE_FEATURES = "debug-tweaks"
IMAGE_LINGUAS = ""

PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_NAME_SUFFIX ?= ""
IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

inherit core-image

IMAGE_FSTYPES = "cpio.xz cpio.gz cpio"
