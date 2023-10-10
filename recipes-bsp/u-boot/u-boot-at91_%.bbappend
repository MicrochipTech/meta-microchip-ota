FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGE_BEFORE_PN += "${PN}-env"
RPROVIDES:${PN}-env += "u-boot-default-env"

SRC_URI:append = " \
        file://add_ext4_fs_config.patch \
"
