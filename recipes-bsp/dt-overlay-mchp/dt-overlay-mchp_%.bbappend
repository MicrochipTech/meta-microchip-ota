FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
        file://0001-add-initramfs.patch \
        ${@bb.utils.contains('VERIFIED_BOOT_HOOKS', '1', 'file://0002-add-verified-boot-nodes.patch', '', d)} \
"

INITRAMFS_IMAGE_NAME = "${@['${INITRAMFS_IMAGE}-${MACHINE}', ''][d.getVar('INITRAMFS_IMAGE') == '']}"

do_copy_initramfs() {
        echo "Copying initramfs to base image deploy directory..."
        if [ -e "${INITRAMFS_DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.${INITRAMFS_TYPE}" ]; then
		cp ${INITRAMFS_DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.${INITRAMFS_TYPE} ${DEPLOY_DIR_IMAGE}/.
        else
                bbfatal "Error, can't find initramfs file ${INITRAMFS_IMAGE_NAME}.${INITRAMFS_TYPE}"
        fi
}

addtask copy_initramfs after do_configure before do_compile

do_copy_initramfs[mcdepends] = "mc:${MAIN_MULTICONFIG}:${INITRAMFS_MULTICONFIG}:initramfs-image:do_image_complete"
do_copy_initramfs[mcdepends] = "mc:${MAIN_MULTICONFIG}:${MAIN_MULTICONFIG}:u-boot:do_deploy"

do_compile:append() {
        if [ "${VERIFIED_BOOT_HOOKS}" -eq "1" ]; then
                if [ -z "${DT_OVERLAY_MCHP_SIGN_KEYDIR}" ]; then
                        bbfatal "Error, DT_OVERLAY_MCHP_SIGN_KEYDIR is not set, please provide path to keys for signing"
                fi
                
                # Over-ride itb target in Makefile
                if [ -e "${AT91BOOTSTRAP_MACHINE}.its" ]; then
                        bbnote "\nCreating signed FIT image and writing public key to u-boot control dtb\n"
                        rm -f u-boot-pki.dtb
                        rm -f u-boot-nodtb.bin
                        rm -f ${AT91BOOTSTRAP_MACHINE}-signed.itb
                        cp ${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.dtb u-boot-pki.dtb
                        cp ${DEPLOY_DIR_IMAGE}/u-boot-nodtb-${MACHINE}.bin u-boot-nodtb.bin
                        DTC_OPTIONS="-Wno-unit_address_vs_reg -Wno-graph_child_address -Wno-pwms_property"
                        mkimage -D "-i${DEPLOY_DIR_IMAGE} -p 1000 ${DTC_OPTIONS}" -f ${AT91BOOTSTRAP_MACHINE}.its \
                                -k ${DT_OVERLAY_MCHP_SIGN_KEYDIR} -r -K u-boot-pki.dtb ${AT91BOOTSTRAP_MACHINE}-signed.itb

                        bbnote "\nConcatenating u-boot.bin and control DTB with public key > u-boot-pki.bin\n"

                        cat u-boot-nodtb.bin u-boot-pki.dtb > u-boot-pki.bin
                else
                        bbnote "\nNo its file to create FIT images\n"
                fi
        fi
}

do_deploy:append() {
        if [ "${VERIFIED_BOOT_HOOKS}" -eq "1" ]; then
                install ${AT91BOOTSTRAP_MACHINE}-signed.itb ${DEPLOYDIR}/${AT91BOOTSTRAP_MACHINE}.itb
                install u-boot-pki.bin ${DEPLOYDIR}/u-boot.bin
                install u-boot-pki.dtb ${DEPLOYDIR}/
        fi
}



