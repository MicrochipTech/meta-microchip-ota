SUMMARY = "Main Image"
LICENSE = "MIT"
PR = "r1"

IMAGE_FSTYPES:append = " ext4 ext4.gz wic.bz2 wic.bmap"

WKS_FILES = "${MACHINE}.wks"

require main-image.inc

remove_systemd_conf_files () {
        rm ${IMAGE_ROOTFS}/lib/systemd/network/80-wired.network
        rm ${IMAGE_ROOTFS}/etc/systemd/network/eth.network
}

ROOTFS_POSTPROCESS_COMMAND:append = "remove_systemd_conf_files;"
