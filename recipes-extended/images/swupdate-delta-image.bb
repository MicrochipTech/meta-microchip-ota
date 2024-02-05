DESCRIPTION = "Microchip Example OTA Delta Image using swupdate"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

DEPENDS = "zchunk-native"

SRC_URI = "\
    file://sw-description \
    file://emmcsetup.lua \
"

IMAGE_DEPENDS = "main-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "main-image"

SWUPDATE_IMAGES_FSTYPES[main-image] = ".ext4.gz"

SWUPDATE_DELTA_ASSET_NAME ?= "${IMAGE_NAME}-${MACHINE}"
BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"
SWUPDATE_DELTA_ASSET_URL ?= ""

do_update_sw_description() {
    # update zck and header filenames if custom name is set in local.conf, otherwise use default
    sed -i "/images: ({/{n;s/.*/\t\t\t\t\tfilename = \"${SWUPDATE_DELTA_ASSET_NAME}.header\";/}" ${WORKDIR}/sw-description

    # update board name set in local.conf
    sed -i "/version =/{n;s/.*/\t${BOARD_NAME} = {/}" ${WORKDIR}/sw-description

    # update hw compatibility version if set in local.conf
    sed -i "s|hardware-compatibility =.*|hardware-compatibility = [\"${BOARD_REV}\"];|" ${WORKDIR}/sw-description

    # update url to server specified in local.conf
    if [ -z "${SWUPDATE_DELTA_ASSET_URL}" ]; then
        bbfatal "SWUPDATE_DELTA_ASSET_URL not set!"
    else
        sed -i "s|url =.*|url = \"${SWUPDATE_DELTA_ASSET_URL}/${SWUPDATE_DELTA_ASSET_NAME}.zck\";|" ${WORKDIR}/sw-description
    fi
}

addtask update_sw_description before do_swupdate_create_delta

do_swupdate_create_delta() {
    $(rm -f ${SWUPDATE_DELTA_ASSET_NAME}.zck)
    $(rm -f ${SWUPDATE_DELTA_ASSET_NAME}.header)
    $(zck --output ${SWUPDATE_DELTA_ASSET_NAME}.zck -u --chunk-hash-type sha256 ${DEPLOY_DIR_IMAGE}/${SWUPDATE_IMAGES}-${MACHINE}.ext4)
    HSIZE=$(zck_read_header -v ${SWUPDATE_DELTA_ASSET_NAME}.zck | grep "Header size" | cut -d ':' -f 2)
    $(dd if=${SWUPDATE_DELTA_ASSET_NAME}.zck of=${SWUPDATE_DELTA_ASSET_NAME}.header bs=1 count="${HSIZE}")

    # sw-description must be first in the CPIO file
    $(ls -f sw-description emmcsetup.lua ${SWUPDATE_DELTA_ASSET_NAME}.header | cpio -ov -H crc > ${SWUPDATE_DELTA_ASSET_NAME}.swu)

    $(cp ${SWUPDATE_DELTA_ASSET_NAME}.swu ${DEPLOY_DIR_IMAGE})
    $(cp ${SWUPDATE_DELTA_ASSET_NAME}.zck ${DEPLOY_DIR_IMAGE})
}

addtask swupdate_create_delta before do_build

do_swupdate_create_delta[dirs] = "${WORKDIR}"
do_swupdate_create_delta[depends] = "${SWUPDATE_IMAGES}:do_image_complete"

do_update_sw_description[dirs] = "${WORKDIR}"
do_update_sw_description[depends] = "${SWUPDATE_IMAGES}:do_image_complete"

do_swuimage[noexec] = "1"
