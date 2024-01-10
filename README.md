This README file contains information on the contents of the meta-microchip-ota layer.

Please see the corresponding sections below for details.

Dependencies
============

  URI: https://github.com/linux4sam/meta-atmel.git \
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
   git clone https://git.yoctoproject.org/poky -b kirkstone \
   git clone https://git.openembedded.org/meta-openembedded -b kirkstone \
   git clone https://git.yoctoproject.org/meta-arm -b kirkstone \
   git clone https://github.com/sbabic/meta-swupdate.git -b kirkstone \
   git clone https://github.com/linux4sam/meta-atmel -b kirkstone \
   git clone https://github.com/MicrochipTech/meta-microchip-ota

### 2. Set up build environment
   sorce poky/oe-init-build-env \
   bitbake-layers add-layer ../meta-openembedded/meta-oe \
   bitbake-layers add-layer ../meta-openembedded/meta-python \
   bitbake-layers add-layer ../meta-openembedded/meta-networking \
   bitbake-layers add-layer ../meta-arm/meta-arm-toolchain \
   bitbake-layers add-layer ../meta-arm/meta-arm \
   bitbake-layers add-layer ../meta-swupdate \
   bitbake-layers add-layer ../meta-atmel \
   bitbake-layers add-layer ../meta-microchip-ota

### 3. Add variables to local.conf
   PACKAGE_CLASSES = "package_ipk" \
   MC_INITRAMFS_NAME = "initramfs" \
   MC_INITRAMFS_TMPDIR = "\${TOPDIR}/tmp-\${MC_INITRAMFS_NAME}" \
   MC_MAIN_NAME = "main" \
   MC_MAIN_TMPDIR = "\${TOPDIR}/tmp-${MC_MAIN_NAME}" \
   BBMULTICONFIG = "\${MC_INITRAMFS_NAME} ${MC_MAIN_NAME}" \
   DISTRO = "poky-atmel" \
   /* If using verified boot add the next two lines, the second being the path to your \
    * private key and certificate.  See secure boot app note for more details \
    * / \
   VERIFIED_BOOT_HOOKS = "1" \
   DT_OVERLAY_MCHP_SIGN_KEYDIR = "/path/to/key_and_cert"

### 4. Build multiconfig image for your target (initramfs and main image)
   ex: MACHINE=sam9x75-curiosity-sd bitbake mc:main:main-image

### 5. Add a package and build a swupdate image (or delta image)
   For example, add the following to main.conf: \
   IMAGE_INSTALL:append:sam9x75-curiosity-sd = " iperf3" 

   Then build the swupdate (or delta) image: \
   MACHINE=sam9x75-curiosity-sd bitbake mc:main:swupdate-image \
      -or \
   MACHINE=sam9x75-curiosity-sd bitbake mc:main:swupdate-delta-image

   Refer to the swupdate documentation for more info on how to deploy