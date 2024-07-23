SUMMARY = "Main Image"
LICENSE = "MIT"
PR = "r1"

IMAGE_FSTYPES:append = " ext4 ext4.gz wic.bz2 wic.bmap"

WKS_FILES = "${MACHINE}.wks"

require main-image.inc

DEPENDS += "egt-swupdate"

IMAGE_INSTALL:append = " \
        config-board-provision \
"

provision_app_data () {
        # create dummy delta update data
        dd if=/dev/urandom bs=1 count=1M > app_data.img
        dd if=/dev/zero bs=1 count=1M >> app_data.img
        dd if=/dev/urandom bs=1 count=1M >> app_data.img

        cp app_data.img ${IMAGE_ROOTFS}/opt/

        # copy app filesystem to /opt, provision script will flash to QSPI
        cp ${DEPLOY_DIR_IMAGE}/egt-swupdate.squashfs ${IMAGE_ROOTFS}/opt/
}

update_swupdate_config () {
        # set the app version in swupdate.cfg
        EGT_SWUPDATE_VER_MAJOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MAJOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER_MINOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MINOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER_PATCH=$(sed -n 's|.*EGT_SWUPDATE_VERSION_PATCH \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER="${EGT_SWUPDATE_VER_MAJOR}.${EGT_SWUPDATE_VER_MINOR}.${EGT_SWUPDATE_VER_PATCH}"
        
        sed -i "/Application/,/},;/s/version =.*/version = \"${EGT_SWUPDATE_VER}\";/" ${IMAGE_ROOTFS}/etc/swupdate.cfg
        sed -i "/identify : (/,/);/s/name = \"App Version\";.*/name = \"App Version\"; value = \"${EGT_SWUPDATE_VER}\"; },/" ${IMAGE_ROOTFS}/etc/swupdate.cfg
}

disable_suricatta () {
        sed -i "s/SWUPDATE_SURICATTA_ARGS=.*/SWUPDATE_SURICATTA_ARGS=\"\"/" ${IMAGE_ROOTFS}/lib/swupdate/conf.d/09-swupdate-args
}

ROOTFS_POSTPROCESS_COMMAND:append = "provision_app_data; update_swupdate_config; disable_suricatta;"
