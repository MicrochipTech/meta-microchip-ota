FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG_CONFARGS = ""

#SRCREV = "362217049f4adbe6c2a741ba7cd28b025859286f"

# file://delta_ssl.patch

inherit externalsrc
EXTERNALSRC = "/opt/src/swupdate"

SRC_URI:append = " \
        file://09-swupdate-args \
        file://swupdate.cfg \
        file://sam9x60-curiosity-sd.cert.pem \
"
do_install:append() {
        install -d ${D}${sysconfdir}
        install -d ${D}${sysconfdir}/swupdate

        install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
        install -m 444 ${WORKDIR}/sam9x60-curiosity-sd.cert.pem ${D}${sysconfdir}/swupdate/ 

}
