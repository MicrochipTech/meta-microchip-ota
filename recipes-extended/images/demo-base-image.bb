SUMMARY = "Demo Base Image"

LICENSE = "MIT"

IMAGE_FEATURES:append = " ssh-server-openssh "
IMAGE_FEATURES:remove = " splash "

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
        swupdate-progress \
        swupdate-tools-hawkbit \
        swupdate-www \
        curl \
	zchunk \
	htop \
	bash-completion \
"

# trick yocto into downloading sources we'll use later by specifying an 
# override for a MACHINE target we wont actually use in the lab
# this is not necessary if you are on an internet connected network
# (i.e not Ethernet static IP, or you have wifi and the static IP at the same time)
IMAGE_INSTALL:append:sama7g5ek-emmc = " \
	nano \
	iperf3 \
"

inherit core-image

