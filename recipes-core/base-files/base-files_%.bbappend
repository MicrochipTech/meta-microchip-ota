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
        install -m 444 ${WORKDIR}${CUSTOM_CA_CERT_PATH}/${CUSTOM_CA_CERT_NAME} ${D}${prefix}/local/share/ca-certificates/
    fi

    echo 'TERM=xterm' >> ${D}${sysconfdir}/profile
    echo 'alias ll="ls -al"' >> ${D}${sysconfdir}/profile    
}

FILES:${PN}:append = " \
    ${prefix}/local/share/ca-certificates/* \    
"
