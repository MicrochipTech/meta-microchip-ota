This README file contains information on the contents of the meta-microchip-ota layer.

Please see the corresponding sections below for details.

Dependencies
============

  URI: https://github.com/linux4sam/meta-atmel.git
  branch: kirkstone

Patches
=======

Please submit any patches against the meta-microchip-ota layer to Matt Wood <matt.wood@microchip.com>

Table of Contents
=================

  I. How to build


I. How to build
=================================================

### 1. Fetch required repos
   git clone https://git.yoctoproject.org/poky -b kirkstone
   git clone https://git.openembedded.org/meta-openembedded -b kirkstone
   git clone https://git.yoctoproject.org/meta-arm -b kirkstone
   git clone https://github.com/sbabic/meta-swupdate.git -b kirkstone
   git clone https://github.com/linux4sam/meta-atmel -b kirkstone
   git clone https://github.com/MicrochipTech/meta-microchip-ota

### 2. Set up build environment
   sorce poky/oe-init-build-env
   bitbake-layers add-layer ../meta-openembedded/meta-oe
   bitbake-layers add-layer ../meta-openembedded/meta-python
   bitbake-layers add-layer ../meta-openembedded/meta-networking
   bitbake-layers add-layer ../meta-arm/meta-arm-toolchain
   bitbake-layers add-layer ../meta-arm/meta-arm
   bitbake-layers add-layer ../meta-swupdate
   bitbake-layers add-layer ../meta-atmel
   bitbake-layers add-layer ../meta-microchip-ota

### 3. Add variables to local.conf
   PACKAGE_CLASSES = "package_ipk"
   MC_INITRAMFS_NAME = "initramfs"
   MC_INITRAMFS_TMPDIR = "${TOPDIR}/tmp-${MC_INITRAMFS_NAME}"
   MC_MAIN_NAME = "main"
   MC_MAIN_TMPDIR = "${TOPDIR}/tmp-${MC_MAIN_NAME}"
   BBMULTICONFIG = "${MC_INITRAMFS_NAME} ${MC_MAIN_NAME}"
   DISTRO = "poky-atmel"

   # Optional variables

   # If using verified boot add the next two lines, the second being the path to your
   # private key and certificate.  See secure boot app note for more details
   VERIFIED_BOOT_HOOKS = "1"
   DT_OVERLAY_MCHP_SIGN_KEYDIR = "/path/to/key_and_cert"

   # Signed update options
   SWUPDATE_SIGNING = "RSA"
   SWUPDATE_PRIVATE_KEY = "/path/to/signing/signing.priv.pem"
   SWUPDATE_PASSWORD_FILE = "/path/to/signing/passwdfile"
   SWUPDATE_SIGNING_PUBKEY_PATH = "/path/to/signing"
   SWUPDATE_SIGNING_PUBKEY_NAME = "signing.pub.pem"
   SWUPDATE_SIGNING_PUBKEY_TARGET_DIR = "/etc/swupdate"

   # Custom name and HW rev for the board - this is used in the sw-description and swupdate.cfg files
   BOARD_NAME = "Custom-Hardware-Name"
   BOARD_REV = "1.0"

   # Suricatta daemon ID value
   SWUPDATE_SURICATTA_ID = "Custom-Name"

   # Server URL for example when using hawkbit or a generic server for delta updates
   SWUPDATE_SERVER_HOSTNAME = "hostname"
   SWUPDATE_SERVER_DOMAIN = "domain.com"
   SWUPDATE_SERVER_URL = "https://${SWUPDATE_SERVER_HOSTNAME}.${SWUPDATE_SERVER_DOMAIN}"
   SWUPDATE_DELTA_ASSET_URL = "${SWUPDATE_SERVER_URL}/artifacts"

   # Custom name for delta update assets (swu, header and zck files)
   SWUPDATE_DELTA_ASSET_NAME = "custom-name"

   # Mutual TLS options for example with nginx and hawkbit.
   # The certificate common name embedded in mTLS certificate
   # must be the same as the id (SWUPDATE_SURICATTA_ID) in swupdate.cfg or with the -i command line option

   # It is possible to use certificate/key stored in the root filesystem by specifying a source and target
   # destination path as well as the file names.  A PKCS#11 token can also be used for the certificate/key
   # in which case the target destination path shall not be set.  The source path can also be omitted in
   # the case of a certificate/key being generated run-time by some startup script for example.
   # The example below shows a certificate held in the filesystem and a key as a PKCS#11 token.
   SWUPDATE_USE_MTLS = "1" \
   SWUPDATE_MTLS_CERT_PATH = "/path/to/certificate" \
   SWUPDATE_MTLS_CERT_NAME = "certificat-name.cert.pem" \
   SWUPDATE_MTLS_TARGET_CERT_DIR = "/etc/swupdate"

   SWUPDATE_MTLS_KEY_NAME = "pkcs11:token=MCHP;object=device;type=private" \
   #SWUPDATE_MTLS_KEY_PATH = "/path/to/private/key" \
   #SWUPDATE_MTLS_TARGET_KEY_DIR = "/etc/swupdate"

   # Use a custom CA certificate for example a self-signed CA for the update artifact server.
   # Note that the suffix must be .crt
   USE_CUSTOM_CA_CERT = "1"
   CUSTOM_CA_CERT_PATH = "/path/to/certs"
   CUSTOM_CA_CERT_NAME = "ca.cert.crt"

### 4. Build multiconfig image for your target (initramfs and main image)
   ex: MACHINE=sama5d27-wlsom1-ek-sd bitbake mc:main:main-image

### 5. Add a package and build a swupdate image (or delta image)
   For example, add the following to conf/multiconfig/main.conf:
   IMAGE_INSTALL:append:sama5d27-wlsom1-ek-sd = " iperf3"

   Then build the swupdate (or delta) image:
   MACHINE=sama5d27-wlsom1-ek-sd bitbake mc:main:swupdate-image
      -or
   MACHINE=sama5d27-wlsom1-ek-sd bitbake mc:main:swupdate-delta-image

   Refer to the swupdate documentation for more info on how to deploy
   