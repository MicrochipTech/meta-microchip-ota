FILESEXTRAPATHS:prepend := "${THISDIR}/systemd:"

SRC_URI:append = " \
        file://systemd-networkd-wait-online.service \
"

do_install:append() {
        install -m 0644 ${WORKDIR}/systemd-networkd-wait-online.service ${D}${systemd_unitdir}/system
}
