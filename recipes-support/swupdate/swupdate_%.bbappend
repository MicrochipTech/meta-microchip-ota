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

inherit swupdate-common

#SWUPDATE_SERVER_URL ?= "http://hostname.com"
SWUPDATE_USE_MTLS ?= "0"
SWUPDATE_MTLS_CERT_PATH ?= "/tmp"
SWUPDATE_MTLS_CERT_NAME ?= "dummy.pem"
SWUPDATE_DELTA_ASSET_URL ?= ""
BOARD_NAME ?= "${MACHINE}"
BOARD_REV ?= "1.0"
SWUPDATE_SURICATTA_ID ?= "${MACHINE}"

SRC_URI:append = " \
        file://defconfig \
        file://01-swupdate-identify \
        file://09-swupdate-args \
        file://swupdate.cfg \
        ${@bb.utils.contains('SWUPDATE_USE_MTLS', '1', 'file://${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME}', '', d)} \
"

do_install:append() {
        # update server URL if set in local.conf
        if [ -z "${SWUPDATE_SERVER_URL}" ]; then
                bbnote "SWUPDATE_SERVER_URL not set, dummy URL will be used"
        else
                sed -i "s|.*url\t\t= \".*|\turl\t\t= \"${SWUPDATE_SERVER_URL}\";|" ${WORKDIR}/swupdate.cfg
        fi

        # if using mTLS update the certificate name and id attribute swupdate.cfg
        if [ "${SWUPDATE_USE_MTLS}" -eq "1" ]; then
                if [ -z "${SWUPDATE_MTLS_CERT_NAME}" -o -z "${SWUPDATE_MTLS_CERT_PATH}" ]; then
                        bbfatal "Error, SWUPDATE_MTLS_CERT_PATH or SWUPDATE_MTLS_CERT_NAME not set!"
                else
                        bbnote "Using certififate in ${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME} for mTLS"
                        sed -i "s|.*/* sslkey.*|\tsslkey\t= \"pkcs11:token=MCHP;object=device;type=private\";|g" ${WORKDIR}/swupdate.cfg
                        sed -i "s|.*/* sslcert.*|\tsslcert\t= \"/etc/swupdate/${SWUPDATE_MTLS_CERT_NAME}\";|g" ${WORKDIR}/swupdate.cfg
                fi
        fi

        # set the id attribute in swupdate.cfg.  If using mTLS, this must be the same as the COMMON NAME in the cert
        sed -i "s|.*id\t\t= \".*|\tid\t\t= \"${SWUPDATE_SURICATTA_ID}\";|" ${WORKDIR}/swupdate.cfg

        # update the 01-swupdate-identify script with the board type if set in local.conf.
        # This is run at boot to get the serial number from the ECC608 and put it
        # in the /etc/swupdate.cfg file.  This should only update the file once.
        sed -i "s|board=.*|board=\"${BOARD_NAME}\"|g" ${WORKDIR}/01-swupdate-identify

        # update the 09-swupdate-args to set the board_name and board_rev which set in local.conf or default values
        sed -i "s|-H.*|-H ${BOARD_NAME}:${BOARD_REV} \${selection} -f /etc/swupdate.cfg\"|g" ${WORKDIR}/09-swupdate-args

        install -d ${D}${sysconfdir}
        install -d ${D}${sysconfdir}/swupdate

        install -m 0644 ${WORKDIR}/01-swupdate-identify ${D}${libdir}/swupdate/conf.d/
        install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
        install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}

        if [ "${SWUPDATE_USE_MTLS}" -eq "1" ]; then
                install -m 444 ${WORKDIR}${SWUPDATE_MTLS_CERT_PATH}/${SWUPDATE_MTLS_CERT_NAME} ${D}${sysconfdir}/swupdate/
        fi
}
