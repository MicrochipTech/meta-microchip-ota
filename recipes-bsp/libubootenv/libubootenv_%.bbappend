FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://LICENSES/LGPL-2.1-or-later.txt;md5=4fbd65380cdd255951079008b364516c"
SRCREV = "3f4d15e36ceb58085b08dd13f3f2788e9299877b"

SRC_URI:append:class-target = " file://fw_env.config"

DEPENDS += "libyaml"

do_install:append:class-target() {
	install -d ${D}${sysconfdir}
	install -m 644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}
}

FILES:${PN}:append:class-target = " ${sysconfdir}"
