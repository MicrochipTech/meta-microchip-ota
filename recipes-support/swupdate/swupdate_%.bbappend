FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# for a build with both images using the same libc, this chooses the correct defconfig if
# you want each image to be built with different options.
# comment these two lines if using split libc build and uncomment the third line below
MC_EXTRA_FILES_PATH = "${@bb.utils.contains('BB_CURRENT_MC', '${MC_INITRAMFS_NAME}', '${MACHINE}/initramfs', '${MACHINE}/main', d)}"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MC_EXTRA_FILES_PATH}:"
#FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:"

# need to create libc-glibc and libc-musl subdirs in the machine folder if you want a different
# defconfig for each image.  This allows FILESOVERRIDES to find the right defconfig during build
# ex: recipes-support/swupdate/swupdate/sam9x75-curiosity-sd/libc-musl/defconfig

# uncomment for split libc build using musl
#LDFLAGS:remove:libc-musl = "-Wl,--gc-sections"

PACKAGECONFIG_CONFARGS = ""

SRCREV = "2042e6dc0f5466bd428f4db18eaff638203150ad"

SRC_URI:append = " \
        file://defconfig \
        file://09-swupdate-args \
        file://swupdate.cfg \
"

do_install:append() {
        install -d ${D}${sysconfdir}
        install -d ${D}${sysconfdir}/swupdate

        install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
}
