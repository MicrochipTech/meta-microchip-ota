DESCRIPTION = "Microchip Example OTA Update Image using swupdate"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://emmcsetup.lua \
    file://sw-description \
"

# main application image
IMAGE_DEPENDS = "main-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "main-image"

SWUPDATE_IMAGES_FSTYPES[main-image] = ".ext4.gz"

do_set_image_name() {
    sed -i "s/image-name/main-image/g" ${WORKDIR}/sw-description
}

addtask set_image_name after do_unpack do_prepare_recipe_sysroot before do_swuimage

