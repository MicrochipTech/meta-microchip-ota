DESCRIPTION = "Microchip Example OTA Delta Image using swupdate"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

DEPENDS = "zchunk-native"

SRC_URI = "\
    file://sw-description \
    file://emmcsetup.lua \
"

IMAGE_DEPENDS = "demo-base-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "demo-base-image"

SWUPDATE_IMAGES_FSTYPES[demo-base-image] = ".ext4.gz"

addtask swupdate_create_delta before do_build

do_swupdate_create_delta() {
        $(rm -f ${IMAGE_LINK_NAME}.zck)
        $(rm -f ${IMAGE_LINK_NAME}.header)
        $(zck --output ${IMAGE_LINK_NAME}.zck -u --chunk-hash-type sha256 ${DEPLOY_DIR_IMAGE}/${SWUPDATE_IMAGES}-${MACHINE}.ext4)
        HSIZE=$(zck_read_header -v ${IMAGE_LINK_NAME}.zck | grep "Header size" | cut -d ':' -f 2)
        $(dd if=${IMAGE_LINK_NAME}.zck of=${IMAGE_LINK_NAME}.header bs=1 count="${HSIZE}")

        # sw-description must be first in the CPIO file
        $(ls -f sw-description emmcsetup.lua ${IMAGE_LINK_NAME}.header | cpio -ov -H crc > ${IMAGE_LINK_NAME}.swu)

        $(cp ${IMAGE_LINK_NAME}.swu ${DEPLOY_DIR_IMAGE})
        $(cp ${IMAGE_LINK_NAME}.zck ${DEPLOY_DIR_IMAGE})

        
}

do_swupdate_create_delta[dirs] = "${WORKDIR}"
do_swupdate_create_delta[depends] = "demo-base-image:do_image_complete"
