DESCRIPTION = "Microchip EGT SWUpdate Training Application"
AUTHOR = "Microchip Technology Inc"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "libegt cairo cryptoauthlib libconfig libubootenv squashfs-tools-native"

SRC_URI = " \
        gitsm://github.com/MicrochipTech/egt-swupdate.git;protocol=https;branch=main \
        file://egt-swupdate.service \
        file://egt-swupdate.png \
        file://egt-swupdate.xml \
"

# Lab 2
SRCREV = "7c86d5ed1d6318dffcfc4d2debab6ea9f16557c4"
PV = "2.0.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit cmake
inherit deploy
inherit pkgconfig
inherit systemd

EXTRA_OECMAKE:append = " \
	-DCMAKE_BUILD_TYPE=MinSizeRel \
"

FILES:${PN}:append = " \
        ${systemd_system_unitdir}/* \
        ${includedir}/* \
        ${datadir}/egt/examples/${PN}/* \
"

SYSTEMD_SERVICE:${PN} = "egt-swupdate.service"

do_install:append() {
        # This is a hack for the Masters training class to show updates.
        # The QSPI flash on the WLSOM1 is used to store the egt-swupdate binary
        # in a squashfs to give us something to update in the various class tasks.

        # The cmake recipe installs the egt-swupdate binary to the default
        # CMAKE_INSTALL_PREFIX, so we remove it and it's install directory to avoid a yocto QA error.

        # Then, create a squashfs image to be used by the config-board provision-qspi service
        # in the provisioning image.  The egt-swupdate-image recipe unsquashes it get the egt-swupdate 
        # binary and then creates its own squashfs image which is used by the egt-swupdate-swu recipe. 
        # This is also a hack to leverage the swupdate-image class to do the work of creating the .swu

        # install the systemd unit in the normal filesystem which points to /opt/app/egt-swupdate

        rm ${D}${bindir}/${PN}
        rmdir ${D}${bindir}
        rmdir ${D}${prefix}
        
        mkdir -p squashfs
        rm -f squashfs/egt-swupdate
        rm -f ${PN}.squashfs
        cp egt-swupdate squashfs

        mksquashfs squashfs ${PN}.squashfs -b 4K -noappend

        install -d ${D}${systemd_system_unitdir}
        install -m 644 ${WORKDIR}/egt-swupdate.service ${D}${systemd_system_unitdir}

        install -d ${D}${datadir}/egt/examples/${PN}
        install -m 644 ${WORKDIR}/egt-swupdate.png ${D}${datadir}/egt/examples/${PN}
        install -m 644 ${WORKDIR}/egt-swupdate.xml ${D}${datadir}/egt/examples/${PN}

        install -d ${D}${includedir}
        install -m 0755 ${B}/version.h ${D}${includedir}/egt-swupdate-version.h
}

addtask deploy after do_install

do_deploy() {
        install ${PN}.squashfs ${DEPLOYDIR}/
}
