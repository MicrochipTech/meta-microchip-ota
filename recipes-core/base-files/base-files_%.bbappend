FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = "\ 
    file://ca-chain.cert.pem \ 
" 

do_install:append() {
    
    install -d ${D}${prefix}/local/share/ca-certificates
    install -m 444 ${WORKDIR}/ca-chain.cert.pem ${D}${prefix}/local/share/ca-certificates/c41329.local-ca-chain.cert.crt 

    echo 'TERM=xterm' >> ${D}${sysconfdir}/profile
    echo 'alias ll="ls -al"' >> ${D}${sysconfdir}/profile    
}

FILES:${PN}:append = " \
    ${prefix}/local/share/ca-certificates/* \    
"