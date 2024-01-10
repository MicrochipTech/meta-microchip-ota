FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
        file://defconfig \
"
VERIFIED_BOOT = "${@bb.utils.contains('VERIFIED_BOOT_HOOKS', '1', '1', '0', d)}"

PACKAGE_BEFORE_PN += "${PN}-env"
RPROVIDES:${PN}-env += "u-boot-default-env"

do_configure:prepend() {
        cp ${WORKDIR}/defconfig ${S}/configs/${UBOOT_MACHINE}
}

# install the u-boot dtb and binary without appended dtb for signed/verified boot
# dt-overlay-mchp will add the public key to the control dtb, concatenate the dtb and binary
# and then sign the FIT image

do_deploy:append() {
        if [ "${VERIFIED_BOOT_HOOKS}" -eq "1" ]; then
                install ${S}/${UBOOT_NODTB_BINARY} ${DEPLOYDIR}/${UBOOT_NODTB_IMAGE}
                ln -sf ${UBOOT_NODTB_IMAGE} ${DEPLOYDIR}/${UBOOT_NODTB_BINARY}
                ln -sf ${UBOOT_NODTB_IMAGE} ${DEPLOYDIR}/${UBOOT_NODTB_SYMLINK}

                install ${S}/${UBOOT_DTB_BINARY} ${DEPLOYDIR}/${UBOOT_DTB_IMAGE}
                ln -sf ${UBOOT_DTB_IMAGE} ${DEPLOYDIR}/${UBOOT_DTB_BINARY}
                ln -sf ${UBOOT_DTB_IMAGE} ${DEPLOYDIR}/${UBOOT_DTB_SYMLINK}
        fi
}

UBOOT_NODTB_IMAGE = "u-boot-nodtb-${MACHINE}-${PV}-${PR}.bin"
UBOOT_NODTB_BINARY = "u-boot-nodtb.bin"
UBOOT_NODTB_SYMLINK = "u-boot-nodtb-${MACHINE}.bin"

UBOOT_DTB_IMAGE = "u-boot-${MACHINE}-${PV}-${PR}.dtb"
UBOOT_DTB_BINARY = "u-boot.dtb"
UBOOT_DTB_SYMLINK = "u-boot-${MACHINE}.dtb"
