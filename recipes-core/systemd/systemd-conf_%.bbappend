FILESEXTRAPATHS:prepend := "${THISDIR}/systemd-conf:"

SRC_URI:append = " \
    file://wlan0.network \
    file://eth0.network \
    file://override.conf \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network
    install -d ${D}${sysconfdir}/systemd/journald.conf.d/
    install -m 0644 ${WORKDIR}/wlan0.network ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/eth0.network ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/override.conf ${D}${sysconfdir}/systemd/journald.conf.d/
}

FILES:${PN}:append = " \
    ${sysconfdir}/systemd/network/* \
    ${sysconfdir}/systemd/journald.conf.d/* \
"
