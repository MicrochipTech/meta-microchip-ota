FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG_CONFARGS = ""

SRCREV = "bb119e235143533747833b5a0b759f69ea6860c7"

SRC_URI:append = " \
        file://09-swupdate-args \
        file://swupdate.cfg \
"

do_install:append() {
        install -d ${D}${sysconfdir}
        install -d ${D}${sysconfdir}/swupdate

        install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
}
