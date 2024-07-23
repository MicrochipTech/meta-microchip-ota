DESCRIPTION = "Lab 3 Update Recipe"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = " \
    file://qspiupdate.lua \
    file://sw-description \
"

# main application image
IMAGE_DEPENDS = "app-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "app-image"

SWUPDATE_IMAGES_FSTYPES[app-image] = ".squashfs"

BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"

# max the version so the app update can happen
# app version will also be checked in images section of sw-description
UPDATE_SW_REV = "65535.65535.65535.65535"

DEPENDS += "egt-swupdate"

PREFERRED_VERSION_egt-swupdate = "2.0.0"

do_update_sw_description() {
     # set Software version of the update - this is checked by swupdate using the -R switch, see swupdate append recipe
    sed -i "/software = {/,/hardware-compatibility/s/.*version =.*/\tversion = \"${UPDATE_SW_REV}\";/" ${WORKDIR}/sw-description

    # update board name if set in local.conf
    sed -i "/reboot =.*/{n; s/.* = {/\t${BOARD_NAME} = {/}" ${WORKDIR}/sw-description

    # update hw compatibility version if set in local.conf
    sed -i "s|hardware-compatibility =.*|hardware-compatibility = [\"${BOARD_REV}\"];|" ${WORKDIR}/sw-description

    # update image attributes
    EGT_SWUPDATE_VER_MAJOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MAJOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
    EGT_SWUPDATE_VER_MINOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MINOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
    EGT_SWUPDATE_VER_PATCH=$(sed -n 's|.*EGT_SWUPDATE_VERSION_PATCH \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
    EGT_SWUPDATE_VER="${EGT_SWUPDATE_VER_MAJOR}.${EGT_SWUPDATE_VER_MINOR}.${EGT_SWUPDATE_VER_PATCH}"

    sed -i "/images: ({/{n;s/.*/\t\t\t\t\tfilename = \"${SWUPDATE_IMAGES}-${MACHINE}.squashfs\";/}" ${WORKDIR}/sw-description
    sed -i "/images:/,/});/s/swupdate_get_sha256(.*/swupdate_get_sha256(${SWUPDATE_IMAGES}-${MACHINE}.squashfs)\";/" ${WORKDIR}/sw-description
    sed -i "/images:/,/});/s/version =.*/version = \"${EGT_SWUPDATE_VER}\";/" ${WORKDIR}/sw-description
}

addtask update_sw_description after do_prepare_recipe_sysroot before do_populate_lic do_swuimage

do_update_sw_description[depends] = "${SWUPDATE_IMAGES}:do_image_complete"
do_update_sw_description[dirs] = "${WORKDIR} "
