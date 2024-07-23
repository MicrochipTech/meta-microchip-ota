SUMMARY = "Create a squashfs image of just the application binary - used by the swu image class"
IMAGE_INSTALL = ""
IMAGE_LINGUAS = ""
PACKAGE_INSTALL = ""

inherit image

IMAGE_FSTYPES = " squashfs"

DEPENDS += "squashfs-tools-native"

PACKAGE_INSTALL = " \
        egt-swupdate \
"

create_qspi_app_partition () {
        # hack to create a squashfs image with only the binary in the root.
        # Delete the rootfs and then unsquash the egt-swupdate binary.
        # The egt-swupdate-swu recipe uses the created squashfs and the
        # swupdate-image class to do the work of creating the .swu
        rm -rf ${IMAGE_ROOTFS}/*
        unsquashfs -d ${IMAGE_ROOTFS} -f ${DEPLOY_DIR_IMAGE}/egt-swupdate.squashfs
}

IMAGE_PREPROCESS_COMMAND:append = "create_qspi_app_partition;"
