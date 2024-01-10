FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
	file://defconfig \
"

# override defconfig
do_configure:prepend() {
        cp "${WORKDIR}/defconfig" "${B}/.config"
}