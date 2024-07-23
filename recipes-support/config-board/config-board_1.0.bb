DESCRIPTION = "systemd configuration and provisioning to run on first boot"
AUTHOR = "Matt Wood"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PV = "1.0"

SRC_URI = " \
        file://config-board.service \
        file://config-board.sh \
        file://provision-qspi.service \ 
        file://provision-qspi.sh \
        file://provision-mtls.service \
        file://provision-mtls.sh \
        file://opt-swupdate.mount \
        file://opt-app.mount \
        file://opt-data.mount \
"
BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"
SW_REV ?= "1.0"
TARGET_HOSTNAME ?= "${MACHINE}"

DEPENDS:append = " update-rc.d-native"

inherit systemd

PACKAGES =+ " \
        ${PN}-provision \
"

FILES:${PN} = " \
        ${systemd_system_unitdir}/config-board.service \
        ${bindir}/config-board.sh \
        ${systemd_system_unitdir}/opt-app.mount \
        ${systemd_system_unitdir}/opt-swupdate.mount \
        ${systemd_system_unitdir}/opt-data.mount \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', '${sysconfdir}/*', d)} \
"

FILES:${PN}-provision = " \
        ${systemd_system_unitdir}/provision-qspi.service \
        ${systemd_system_unitdir}/provision-mtls.service \
        ${bindir}/provision-qspi.sh \
        ${bindir}/provision-mtls.sh \
"

SYSTEMD_PACKAGES = "${PN} ${PN}-provision"
SYSTEMD_SERVICE:${PN} = "config-board.service"
SYSTEMD_SERVICE:${PN}-provision = "provision-qspi.service provision-mtls.service"

do_install () {
        # if using MTLS set and SWUPDATE_MTLS_TARGET_CERT_DIR is set (i.e not a PKCS#11 token) then 
        # set the cert path.  provision-mtls.sh should be changed if using PKCS#11!!!
        if [ "${SWUPDATE_USE_MTLS}" -eq "1" -a -n "${SWUPDATE_MTLS_TARGET_CERT_DIR}" ]; then
                sed -i "s|cert_path=.*|cert_path=\"${SWUPDATE_MTLS_TARGET_CERT_DIR}\"|" ${WORKDIR}/config-board.sh
                sed -i "s|cert_path=.*|cert_path=\"${SWUPDATE_MTLS_TARGET_CERT_DIR}\"|" ${WORKDIR}/provision-mtls.sh
                sed -i "s|Where=.*|Where=${SWUPDATE_MTLS_TARGET_CERT_DIR}|" ${WORKDIR}/opt-swupdate.mount
        fi

        sed -i "s|hostname=.*|hostname=\"${SWUPDATE_SERVER_HOSTNAME}\"|" ${WORKDIR}/provision-mtls.sh
        sed -i "s|domain=.*|domain=\"${SWUPDATE_SERVER_DOMAIN}\"|" ${WORKDIR}/provision-mtls.sh

        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
                install -d ${D}${systemd_system_unitdir}
                install -d ${D}${bindir}
                install -m 644 ${WORKDIR}/config-board.service ${D}${systemd_system_unitdir}
                install -m 644 ${WORKDIR}/provision-qspi.service ${D}${systemd_system_unitdir}
                install -m 644 ${WORKDIR}/provision-mtls.service ${D}${systemd_system_unitdir}
                install -m 644 ${WORKDIR}/opt-swupdate.mount ${D}${systemd_system_unitdir}
                install -m 644 ${WORKDIR}/opt-app.mount ${D}${systemd_system_unitdir}
                install -m 644 ${WORKDIR}/opt-data.mount ${D}${systemd_system_unitdir}
                
                install -m 755 ${WORKDIR}/config-board.sh ${D}${bindir}
                install -m 755 ${WORKDIR}/provision-qspi.sh ${D}${bindir}
                install -m 755 ${WORKDIR}/provision-mtls.sh ${D}${bindir}
        else
                install -d ${D}${sysconfdir}/init.d
                install -d ${D}${sysconfdir}/rc5.d

                install -m 755 ${WORKDIR}/config-board.sh ${D}${sysconfdir}/init.d
                
                update-rc.d -r ${D} config-board.sh start 01 5 .
        fi
}
