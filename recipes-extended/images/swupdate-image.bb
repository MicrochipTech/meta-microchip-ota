DESCRIPTION = "Microchip Example OTA Update Image using swupdate"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://emmcsetup.lua \
    file://sw-description \
"

# main application image base
IMAGE_DEPENDS = "base-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "base-image"

SWUPDATE_IMAGES_FSTYPES[base-image] = ".ext4.gz"

