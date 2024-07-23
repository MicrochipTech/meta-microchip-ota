FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

MC_EXTRA_FILES_PATH = "${@bb.utils.contains('BB_CURRENT_MC', '${MC_INITRAMFS_NAME}', '${MACHINE}/initramfs', '${MACHINE}/main', d)}"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MC_EXTRA_FILES_PATH}:"

# uncomment for split libc build using musl
LDFLAGS:remove:libc-musl = "-Wl,--gc-sections"

PACKAGECONFIG_CONFARGS = ""

# 2024.05.2 + fix for no reboot json parsing
SRCREV = "077ef4fc63e58c830ed99a44c7aa549247e039bb"

inherit swupdate-common

DEPENDS += "egt-swupdate"

SWUPDATE_USE_MTLS ?= "0"
SWUPDATE_MTLS_CERT_PATH ?= ""
SWUPDATE_MTLS_CERT_NAME ?= "default.cert.pem"
SWUPDATE_MTLS_KEY_PATH ?= ""
SWUPDATE_MTLS_KEY_NAME ?= "default.key.pem"
SWUPDATE_MTLS_TARGET_CERT_DIR ?= ""
SWUPDATE_MTLS_TARGET_KEY_DIR ?= ""
SWUPDATE_DELTA_ASSET_URL ?= ""
BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"
SW_REV ?= "1.0"
SWUPDATE_SURICATTA_ID ?= "${MACHINE}"

SWUPDATE_SIGNING ?= ""
SWUPDATE_SIGNING_PUBKEY_TARGET_DIR ?= ""
SWUPDATE_SIGNING_PUBKEY_NAME ?= ""
SWUPDATE_SIGNING_PUBKEY_PATH ?= ""

SRC_URI:append = " \
        file://defconfig \
        file://09-swupdate-args \
        file://swupdate.cfg \
        file://swupdate-progress.service \
        file://90-start-progress \
        ${@ 'file://${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME}' if d.getVar('SWUPDATE_MTLS_CERT_PATH', True) else ''} \
        ${@ 'file://${SWUPDATE_MTLS_KEY_PATH}/${SWUPDATE_MTLS_KEY_NAME}' if d.getVar('SWUPDATE_MTLS_KEY_PATH', True) else ''} \
        ${@bb.utils.contains('SWUPDATE_SIGNING', 'RSA', 'file://${SWUPDATE_SIGNING_PUBKEY_PATH}/${SWUPDATE_SIGNING_PUBKEY_NAME}', '', d)} \
        file://swupdate-trigger \
        file://0001-Fix-hawkbit-report-when-no-reboot-is-set.patch \
"

FILES:${PN}:append = " \
        ${SWUPDATE_MTLS_TARGET_CERT_DIR}/* \
        ${SWUPDATE_MTLS_TARGET_KEY_DIR}/* \
        ${@bb.utils.contains('SWUPDATE_SIGNING', 'RSA', '${SWUPDATE_SIGNING_PUBKEY_TARGET_DIR}/${SWUPDATE_SIGNING_PUBKEY_NAME}', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', '${sysconfdir}/*', d)} \
"

DEPENDS:append = " update-rc.d-native"

do_install:append() {
        # update server URL if set in local.conf
        if [ -z "${SWUPDATE_SERVER_URL}" ]; then
                bbnote "SWUPDATE_SERVER_URL not set, dummy URL will be used"
        else
                sed -i "/suricatta :/,/};/s|url.*|url\t\t= \"${SWUPDATE_SERVER_URL}\";|" ${WORKDIR}/swupdate.cfg
        fi

        # set the id attribute.  If using mTLS, this must be the same as the COMMON NAME in the cert
        sed -i "/suricatta :/,/};/s/\tid\t\t=.*/\tid\t\t= \"${SWUPDATE_SURICATTA_ID}\";/" ${WORKDIR}/swupdate.cfg

        # set HW and SW version info in versions block
        sed -i "/Software/,/},;/s/version =.*/version = \"${SW_REV}\";/" ${WORKDIR}/swupdate.cfg


        # set HW and SW version info in identify block
        sed -i "/identify : (/,/);/s/name = \"board\";.*/name = \"board\"; value = \"${BOARD_NAME}\"; },/" ${WORKDIR}/swupdate.cfg
        sed -i "/identify : (/,/);/s/name = \"HW Version\";.*/name = \"HW Version\"; value = \"${BOARD_REV}\"; },/" ${WORKDIR}/swupdate.cfg
        sed -i "/identify : (/,/);/s/name = \"SW Version\";.*/name = \"SW Version\"; value = \"${SW_REV}\"; },/" ${WORKDIR}/swupdate.cfg

        # if using mTLS update attributes and paths
        if [ "${SWUPDATE_USE_MTLS}" -eq "1" ]; then
                if [ -z "${SWUPDATE_MTLS_TARGET_CERT_DIR}" ]; then
                        # path is not required as it could be a PKCS#11 token
                        bbnote "SWUPDATE_MTLS_TARGET_CERT_DIR not set (PKCS#11 token?)"
                        sed -i "s|.*/* sslcert.*|\tsslcert\t\t= \"${SWUPDATE_MTLS_CERT_NAME}\";|g" ${WORKDIR}/swupdate.cfg
                else
                        sed -i "s|.*/* sslcert.*|\tsslcert\t\t= \"${SWUPDATE_MTLS_TARGET_CERT_DIR}/${SWUPDATE_MTLS_CERT_NAME}\";|g" ${WORKDIR}/swupdate.cfg
                fi

                if [ -z "${SWUPDATE_MTLS_TARGET_KEY_DIR}" ]; then
                        # path is not required as it could be a PKCS#11 token
                        bbnote "SWUPDATE_MTLS_TARGET_KEY_DIR not set (PKCS#11 token?)"
                        sed -i "s|.*/* sslkey.*|\tsslkey\t\t= \"${SWUPDATE_MTLS_KEY_NAME}\";|g" ${WORKDIR}/swupdate.cfg
                else
                        sed -i "s|.*/* sslkey.*|\tsslkey\t\t= \"${SWUPDATE_MTLS_TARGET_KEY_DIR}/${SWUPDATE_MTLS_KEY_NAME}\";|g" ${WORKDIR}/swupdate.cfg
                fi

                # if the cert path is set then place the cert in the target directory set in local.conf or in the default location
                if [ -n "${SWUPDATE_MTLS_CERT_PATH}" ]; then
                        if [ -z "${SWUPDATE_MTLS_TARGET_CERT_DIR}" ]; then
                                bbnote "SWUPDATE_MTLS_TARGET_CERT_DIR not set, installing mTLS certificate to default directory /etc/swupdate"
                                install -d ${D}${sysconfdir}/swupdate
                                install -m 444 ${WORKDIR}${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME} ${D}${sysconfdir}/swupdate/
                        else
                                install -d ${D}${SWUPDATE_MTLS_TARGET_CERT_DIR}
                                install -m 444 ${WORKDIR}${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME} ${D}${SWUPDATE_MTLS_TARGET_CERT_DIR}/
                        fi
                fi

                # if the key path is set then place the key in the target directory set in local.conf or in the default location
                if [ -n "${SWUPDATE_MTLS_KEY_PATH}" ]; then
                        if [ -z "${SWUPDATE_MTLS_TARGET_KEY_DIR}" ]; then
                                bbnote "SWUPDATE_MTLS_TARGET_KEY_DIR not set, installing mTLS private key to default directory /etc/swupdate"
                                install -d ${D}${sysconfdir}/swupdate
                                install -m 444 ${WORKDIR}${SWUPDATE_MTLS_KEY_PATH}/${SWUPDATE_MTLS_KEY_NAME} ${D}${sysconfdir}/swupdate/
                        else
                                install -d ${D}${SWUPDATE_MTLS_TARGET_KEY_DIR}
                                install -m 444 ${WORKDIR}${SWUPDATE_MTLS_KEY_PATH}/${SWUPDATE_MTLS_KEY_NAME} ${D}${SWUPDATE_MTLS_TARGET_KEY_DIR}/
                        fi
                fi
        fi

        # if RSA signed updates are enabled, set the public key file
        if [ "${SWUPDATE_SIGNING}" = "RSA" ]; then
                if [ -z "${SWUPDATE_SIGNING_PUBKEY_TARGET_DIR}" ]; then
                        bbfail "Error, SWUPDATE_SIGNING_PUBKEY_TARGET_DIR not set!"
                else
                        sed -i "/globals :/,/};/s|.*public-key-file.*|\tpublic-key-file = \"${SWUPDATE_SIGNING_PUBKEY_TARGET_DIR}/${SWUPDATE_SIGNING_PUBKEY_NAME}\";|" ${WORKDIR}/swupdate.cfg

                        install -d ${D}${SWUPDATE_SIGNING_PUBKEY_TARGET_DIR}
                        install -m 444 ${WORKDIR}${SWUPDATE_SIGNING_PUBKEY_PATH}/${SWUPDATE_SIGNING_PUBKEY_NAME} ${D}${SWUPDATE_SIGNING_PUBKEY_TARGET_DIR}/
                fi
        fi

        # initramfs specific items
        if ${@bb.utils.contains('BB_CURRENT_MC', '${MC_INITRAMFS_NAME}', 'true', 'false', d)}; then
                # update the 09-swupdate-args to remove the automatic reply to hawkbit after update install
                # this will be handled by the app
                sed -i "s/-c 2/ /" ${WORKDIR}/09-swupdate-args

                # remove selection argument since we are not using the double copy architecture when
                # updating from initramfs (Masters labs)
                sed -i "s|SWUPDATE_ARGS.*|SWUPDATE_ARGS=\"-R ${SW_REV} -H ${BOARD_NAME}:${BOARD_REV} -f /etc/swupdate.cfg\"|" ${WORKDIR}/09-swupdate-args

                # trigger script to immediately check for an upadate after swupdate connects to suricatta
                install -d ${D}${sysconfdir}/init.d
                install -d ${D}${sysconfdir}/rc5.d

                install -m 755 ${WORKDIR}/swupdate-trigger ${D}${sysconfdir}/init.d

                update-rc.d -r ${D} swupdate-trigger start 99 5 .
        fi

        # set the board_name and board_rev from local.conf or default values if not set
        # these are also set in swupdate.cfg identify section from the config-board run-time script, see recipe
        sed -i "s|SWUPDATE_ARGS.*|SWUPDATE_ARGS=\"-R ${SW_REV} -H ${BOARD_NAME}:${BOARD_REV} \${selection} -f /etc/swupdate.cfg\"|" ${WORKDIR}/09-swupdate-args

        install -d ${D}${sysconfdir}

        install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
}
