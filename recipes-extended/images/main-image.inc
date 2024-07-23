IMAGE_FEATURES:append = " ssh-server-openssh"

IMAGE_INSTALL = " \
        packagegroup-core-boot \
        kernel-modules \
        openssh \
        openssl \
        openssl-engines \
        avahi-daemon \
        i2c-tools \
        cryptoauthlib \
        python3-cryptoauthlib \
        p11-kit \
        libubootenv-bin \
        swupdate \
        swupdate-www \
        swupdate-progress \
        swupdate-usb \
        swupdate-tools-ipc \
        curl \
        zchunk \
        htop \
        bash-completion \
        libegt \
        noto-fonts \
        liberation-fonts \
        libplanes \
        libdrm \
        wpa-supplicant \
        mchp-wireless-firmware \
        wireless-regdb-static \
        net-tools \
        coreutils \
        nano \
        libconfig++ \
        mtd-utils \
        mtd-utils-jffs2 \
        config-board \
        egt-swupdate \
"

IMAGE_INSTALL:remove:sama7g5 = " \
        libegt \
        egt-swupdate \
        noto-fonts \
        liberation-fonts \
        libplanes \
        libdrm \
        wpa-supplicant \
        mchp-wireless-firmware \
        wireless-regdb-static \
"

inherit core-image

do_image[mcdepends] = "mc:${MAIN_MULTICONFIG}:${INITRAMFS_MULTICONFIG}:initramfs-image:do_image_complete"

# remove this python function to allow systemd firstboot units to run
# we use this for a first boot provisioning script
IMAGE_PREPROCESS_COMMAND:remove = "systemd_preset_all;"
