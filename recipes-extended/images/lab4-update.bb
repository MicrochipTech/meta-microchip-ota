DESCRIPTION = "Lab 5 Update Recipe - Delta Update"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

DEPENDS += "zchunk-native"

SRC_URI = " \
        file://sw-description \
        file://deltaupdate.lua \
"

IMAGE_DEPENDS = "delta-image"

# images and files that will be used for the deployable swupdate image (.swu)
SWUPDATE_IMAGES = "delta-image"

SWUPDATE_IMAGES_FSTYPES[app-image] = ".ext4"

BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"

# max the version so the app update can happen
# app version will also be checked in images section of sw-description
UPDATE_SW_REV = "65535.65535.65535.65535"


do_update_sw_description() {
        # set Software version
        sed -i "/software = {/,/hardware-compatibility/s/.*version =.*/\tversion = \"${UPDATE_SW_REV}\";/" ${WORKDIR}/sw-description

        # update board name set in local.conf
        sed -i "/reboot =.*/{n; s/.* = {/\t${BOARD_NAME} = {/}" ${WORKDIR}/sw-description

        # update hw compatibility version if set in local.conf
        sed -i "s|hardware-compatibility =.*|hardware-compatibility = [\"${BOARD_REV}\"];|" ${WORKDIR}/sw-description

        sed -i "s/image-name-machine/${SWUPDATE_DELTA_ASSET_NAME}/" ${WORKDIR}/sw-description

        # update url to server specified in local.conf
        if [ -z "${SWUPDATE_DELTA_ASSET_URL}" ]; then
                bbfatal "SWUPDATE_DELTA_ASSET_URL not set!"
        else
                sed -i "s|http://hostname.com|${SWUPDATE_DELTA_ASSET_URL}|" ${WORKDIR}/sw-description
        fi
}

# TODO:  Add this functionality to swupdate-common.bbclass
addtask update_sw_description before do_swupdate_create_delta after do_prepare_recipe_sysroot

do_swupdate_create_delta() {
        $(rm -f ${SWUPDATE_DELTA_ASSET_NAME}.zck)
        $(rm -f ${SWUPDATE_DELTA_ASSET_NAME}.header)
        $(rm -f sw-description.sig)
        $(zck --output ${SWUPDATE_DELTA_ASSET_NAME}.zck -u --chunk-hash-type sha256 ${DEPLOY_DIR_IMAGE}/${SWUPDATE_IMAGES}-${MACHINE}.ext4)
        HSIZE=$(zck_read_header -v ${SWUPDATE_DELTA_ASSET_NAME}.zck | grep "Header size" | cut -d ':' -f 2)
        $(dd if=${SWUPDATE_DELTA_ASSET_NAME}.zck of=${SWUPDATE_DELTA_ASSET_NAME}.header bs=1 count="${HSIZE}")
        
        # sw-description must be first in the CPIO file
        if [ "${SWUPDATE_SIGNING}" = "RSA" ]; then
                # compute sha256 hashes for any artifacts in sw-description
                HEADER_DGST=$(sha256sum ${SWUPDATE_DELTA_ASSET_NAME}.header | sed "s|\s.*||")
                SCRIPT_DGST=$(sha256sum deltaupdate.lua | sed "s|\s.*||")

                sed -i "/images:/,/})/s/\$swupdate_get_sha256(.*/${HEADER_DGST}\";/" sw-description
                sed -i "/scripts:/,/})/s/\$swupdate_get_sha256(.*/${SCRIPT_DGST}\";/" sw-description

                $(openssl dgst -sha256 -sign ${SWUPDATE_PRIVATE_KEY} -passin file:${SWUPDATE_PASSWORD_FILE} sw-description > sw-description.sig)
                
                $(ls -f sw-description sw-description.sig deltaupdate.lua ${SWUPDATE_DELTA_ASSET_NAME}.header | cpio -ov -H crc > ${SWUPDATE_DELTA_ASSET_NAME}.swu)
        else
                $(ls -f sw-description deltaupdate.lua ${SWUPDATE_DELTA_ASSET_NAME}.header | cpio -ov -H crc > ${SWUPDATE_DELTA_ASSET_NAME}.swu)
        fi

        $(cp ${SWUPDATE_DELTA_ASSET_NAME}.swu ${DEPLOY_DIR_IMAGE})
        $(cp ${SWUPDATE_DELTA_ASSET_NAME}.zck ${DEPLOY_DIR_IMAGE})
}

addtask swupdate_create_delta before do_build

do_update_sw_description[dirs] = "${WORKDIR}"
do_swupdate_create_delta[dirs] = "${WORKDIR}"
do_update_sw_description[depends] = "${SWUPDATE_IMAGES}:do_image_complete"
do_swupdate_create_delta[depends] = "${SWUPDATE_IMAGES}:do_image_complete"
do_swuimage[noexec] = "1"

# force rebuild of swu image including sha256 checksums
do_unpack[nostamp] = "1"
