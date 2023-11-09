FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    
    install -d ${D}${prefix}/local/share/ca-certificates

    echo 'TERM=xterm' >> ${D}${sysconfdir}/profile
    echo 'alias ll="ls -al"' >> ${D}${sysconfdir}/profile    
}

FILES:${PN}:append = " \
    ${prefix}/local/share/ca-certificates/* \    
"