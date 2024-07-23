FILESEXTRAPATHS:prepend := "${THISDIR}/linux-mchp-6.1.55:"

# for ECC608B-TRUST kit
SRC_URI:append:sam9x75-curiosity-sd = " \
	file://0001-add-mikroebus-i2c-support.patch \
"

# enable sysrq in all builds
SRC_URI:append = " \
	file://sysrq.cfg \
"

SRC_URI:append:sama5d27-wlsom1-ek-sd = " \
	file://0001-set-qspi-partitions.patch \
	file://filesystems.cfg \
"

KERNEL_MODULE_AUTOLOAD:remove = " \
	g_serial \
	atmel_usba_udc \
"
