FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

USE_CUSTOM_CA_CERT ?= "0"
CUSTOM_CA_CERT_PATH ?= ""
CUSTOM_CA_CERT_NAME ?= ""

SRC_URI:append = " \
    ${@bb.utils.contains('USE_CUSTOM_CA_CERT', '1', 'file://${CUSTOM_CA_CERT_PATH}/${CUSTOM_CA_CERT_NAME}', '', d)} \
"

do_install:append() {
    if [ "${USE_CUSTOM_CA_CERT}" -eq "1" ]; then
        install -d ${D}${prefix}/local/share/ca-certificates
        install -m 444 ${WORKDIR}${CUSTOM_CA_CERT_PATH}/${CUSTOM_CA_CERT_NAME} ${D}${prefix}/local/share/ca-certificates/${SWUPDATE_SERVER_HOSTNAME}.cert.crt
    fi

    echo 'TERM=xterm' >> ${D}${sysconfdir}/profile
    echo 'alias ls="ls --color=auto"' >> ${D}${sysconfdir}/profile
    echo 'alias ll="ls -al"' >> ${D}${sysconfdir}/profile

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}; then
        install -d ${D}/opt/swupdate
        echo "/dev/mtdblock0        /opt/swupdate       jffs2    defaults,rw,noatime    0 0" >> ${D}${sysconfdir}/fstab
    fi
}

FILES:${PN}:append = " \
    ${prefix}/local/share/ca-certificates/* \
"
