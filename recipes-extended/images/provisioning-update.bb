DESCRIPTION = "Create an swu artifact of the provisioning image"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://provisioning.lua \
    file://sw-description \
"

# main application image
IMAGE_DEPENDS = "provisioning-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "provisioning-image"

SWUPDATE_IMAGES_FSTYPES[provisioning-image] = ".ext4.gz"

SW_REV ?= "1.0.0"
BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"
UPDATE_SW_REV = "65535.65535.65535.65535"

do_update_sw_description() {
    # set software version
    sed -i "/software = {/,/hardware-compatibility/s/.*version =.*/\tversion = \"${UPDATE_SW_REV}\";/" ${WORKDIR}/sw-description

    # update board name set in local.conf
    sed -i "/reboot =.*/{n; s/.* = {/\t${BOARD_NAME} = {/}" ${WORKDIR}/sw-description

    # update hw compatibility version if set in local.conf
    sed -i "s|hardware-compatibility =.*|hardware-compatibility = [\"${BOARD_REV}\"];|" ${WORKDIR}/sw-description

    # update filenames
    sed -i "/images: ({/{n;s/.*/\t\t\t\t\tfilename = \"${SWUPDATE_IMAGES}-${MACHINE}.ext4.gz\";/}" ${WORKDIR}/sw-description
    sed -i "/images:/,/});/s/swupdate_get_sha256(.*/swupdate_get_sha256(${SWUPDATE_IMAGES}-${MACHINE}.ext4.gz)\";/" ${WORKDIR}/sw-description
    sed -i "/images:/,/});/s/version =.*/version = \"${UPDATE_SW_REV}\";/" ${WORKDIR}/sw-description
}

addtask update_sw_description after do_unpack do_prepare_recipe_sysroot before do_swuimage
