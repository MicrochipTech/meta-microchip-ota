SUMMARY = "Main Image"

LICENSE = "MIT"

IMAGE_FEATURES:append = " ssh-server-openssh"

IMAGE_FSTYPES:append = " ext4 ext4.gz wic.bz2 wic.bmap"

WKS_FILES = "${MACHINE}.wks"

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
        swupdate-progress \
	swupdate-www \
        curl \
	zchunk \
	htop \
	bash-completion \
	libegt \
        noto-fonts \
        liberation-fonts \
        libplanes \
        libdrm \
"

IMAGE_INSTALL:remove:sama7g5 = " \
	libegt \
        noto-fonts \
        liberation-fonts \
        libplanes \
        libdrm \
"

inherit core-image

do_image[mcdepends] = "mc:${MAIN_MULTICONFIG}:${INITRAMFS_MULTICONFIG}:initramfs-image:do_image_complete"
