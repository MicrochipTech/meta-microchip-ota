FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
        file://wpa_supplicant-wlan0.conf \
"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
                install -d ${D}${sysconfdir}/wpa_supplicant
                install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
        fi

        install -m 600 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant.conf
}

FILES:${PN}:append = " \
        ${sysconfdir}/wpa_supplicant.conf \
"
