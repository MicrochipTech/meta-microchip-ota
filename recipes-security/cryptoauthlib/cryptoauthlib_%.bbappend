FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit cmake

EXTRA_OECMAKE += " \
    -DBUILD_TESTS=ON \
"

SRC_URI:append:${MACHINE} = " \
    file://0.conf \
"

do_install:append () {
    install -d ${D}${bindir}
    install	-m 0755 ${WORKDIR}/build/cryptoauth_test ${D}${bindir}
}

do_install:append:${MACHINE} () {
    install -m 644 ${WORKDIR}/0.conf ${D}${localstatedir}/lib/cryptoauthlib/0.conf
    install -Dm 644 ${WORKDIR}/cryptoauthlib.module ${D}${datadir}/p11-kit/modules/cryptoauthlib.module
}

FILES:${PN}:append = " \
    ${bindir}/cryptoauth_test \
"
