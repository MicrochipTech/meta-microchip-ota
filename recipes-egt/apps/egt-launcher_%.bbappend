FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
	file://egtdemo.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN}:append = " \
	egtdemo.service \
"

do_install:append () {
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/egtdemo.service ${D}${systemd_system_unitdir}
}

FILES:${PN}:append = " \
	${systemd_system_unitdir}/egtdemo.service \
"
