SUMMARY = "Lab 1 Webserver Image"
LICENSE = "MIT"
PR = "r1"

IMAGE_FSTYPES:append = " ext4 ext4.gz wic.bz2 wic.bmap"

WKS_FILES = "${MACHINE}.wks"

require main-image.inc

IMAGE_INSTALL:append = " \
        psplash \
        egt-launcher \
"

DEPENDS += "egt-swupdate systemd"

UPDATE_SW_REV = "1.1.0"

disable_egt_swupdate_service () {
        if systemctl >/dev/null 2>/dev/null; then
                bbnote "Disabling egt-swupdate systemd service"
        	systemctl "--root=${IMAGE_ROOTFS}" mask egt-swupdate.service
	else
                bbfatal "Error disabling systemd service"
        fi
}

update_swupdate_env () {
        # set the app version in swupdate.cfg
        EGT_SWUPDATE_VER_MAJOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MAJOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER_MINOR=$(sed -n 's|.*EGT_SWUPDATE_VERSION_MINOR \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER_PATCH=$(sed -n 's|.*EGT_SWUPDATE_VERSION_PATCH \(.*\)|\1|p' ${STAGING_DIR_TARGET}/usr/include/egt-swupdate-version.h)
        EGT_SWUPDATE_VER="${EGT_SWUPDATE_VER_MAJOR}.${EGT_SWUPDATE_VER_MINOR}.${EGT_SWUPDATE_VER_PATCH}"
        
        sed -i "/Software/,/},;/s/version =.*/version = \"${UPDATE_SW_REV}\";/" ${IMAGE_ROOTFS}/etc/swupdate.cfg
        sed -i "/Application/,/},;/s/version =.*/version = \"${EGT_SWUPDATE_VER}\";/" ${IMAGE_ROOTFS}/etc/swupdate.cfg
        sed -i "/identify : (/,/);/s/name = \"SW Version\";.*/name = \"SW Version\"; value = \"${UPDATE_SW_REV}\"; },/" ${IMAGE_ROOTFS}/etc/swupdate.cfg
        sed -i "/identify : (/,/);/s/name = \"App Version\";.*/name = \"App Version\"; value = \"${EGT_SWUPDATE_VER}\"; },/" ${IMAGE_ROOTFS}/etc/swupdate.cfg

        # update the 09-swupdate-args
        sed -i "s|SWUPDATE_ARGS.*|SWUPDATE_ARGS=\"-R ${UPDATE_SW_REV} -H ${BOARD_NAME}:${BOARD_REV} \${selection} -f /etc/swupdate.cfg\"|" ${IMAGE_ROOTFS}/lib/swupdate/conf.d/09-swupdate-args
}

ROOTFS_POSTPROCESS_COMMAND:append = "update_swupdate_env; disable_egt_swupdate_service;"
