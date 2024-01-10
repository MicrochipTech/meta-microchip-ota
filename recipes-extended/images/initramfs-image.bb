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
        swupdate-www \
        i2c-tools \
        avahi-daemon \
"

IMAGE_FEATURES = "debug-tweaks"
IMAGE_LINGUAS = ""

PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_NAME_SUFFIX ?= ""
IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

inherit core-image

IMAGE_FSTYPES = "cpio.xz cpio.gz cpio"

