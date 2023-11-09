FILESEXTRAPATHS:prepend := "${THISDIR}/linux-mchp-6.1.55:"

SRC_URI:append:sam9x75-curiosity-sd = " \
	file://add_mikrobus_i2c_support.patch \
"